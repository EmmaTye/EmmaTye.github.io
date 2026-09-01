---
layout: post
title: "An Algebra of Types"
date: 2026-04-20 15:15:00 +0000
tags: type-theory representations
---

Currently, I'm looking into erganomic (for the programmer) and efficient representations of data types. However, these two properties often conflict with each other. A data type that's easy to reason about and write programs using might be extremely inefficient in its memory layout, and vice versa. Wouldn't it be nice if we could get the best of both worlds - without sacrificing any type-level guarantees about programs?

## Basic notion of ADTs

In most functional programming languages (I'll be using Haskell for this post, but OCaml/Agda/Idris also follow these rules) algebraic data types (ADTs) are all "sums-of-products": alternative constructors that each takes its own number (and type) of arguments (which could be other data types).

Think of a binary tree:

{% highlight haskell %}
data BinTree a = Emp | Node a (BinTree a) (BinTree a)
{% endhighlight %}

The data type `BinTree` has 2 possible constructors - `Empty` and `Node`, with `Empty` taking no arguments and `Node` taking 3 - an `a`, and 2 sub-trees. This is algebraic in a way: we have the "sum" of 2 constructors, which are repsectively the unit and the product of `a` and 2 subtrees:

{% highlight text %}
BinTree a = 1 + (a * (BinTree a) * (BinTree a))
{% endhighlight %}

In memory, a value of a data type like this is normally represented by a tag for its constructor (injection into the sum type), followed by all the information in that constructor (the product). So our `BinTree` values would look something like these:

{:.text-align-center}
![Emp memory layout](/assets/bin-tree-mem-emp.svg){:width="15%"}
![Node memory layout](/assets/bin-tree-mem-node.svg){:width="60%"}

Note that this is a recursive data type, so we don't know how big the type is going to get. We could unfold the `BinTree a` definition in the subtrees any number of times. Usually these recursive arguments are "boxed", with a pointer in memory to the next subtree, so that we know statically how big a "top-level" tree can be.

For our purposes, let's only consider finite data types - ones where we can tell statically the maximum size of any value. We then don't have to worry about pointer arithmetic or memory overflows. Technically a pointer is a finite type, normally 32 or 64 bits, so if we treat pointers as simply bounded integers, we can encode recursive data types.

## Finite Binary Trees

Let's change the definition of `BinTree a` slightly to only consider trees of maximum depth 3:

{% highlight haskell %}
data BinTree3 a = Emp3 | Node3 a (BinTree2 a) (BinTree2 a)
data BinTree2 a = Emp2 | Node2 a (BinTree1 a) (BinTree1 a)
data BinTree1 a = Emp1 | Leaf a
{% endhighlight %}

> N.B. It seems like we have to write a lot of boilerplate to denote trees of maximum depth, but we could use Template Haskell to generate the `BinTree<n>` types and relevant functions for us (up to some `n`).

This data type is quite nice to work with - we can write a simple height function with minimal pattern matching and duplication (barring what can be generated with Template Haskell):

{% highlight haskell %}
heightBinTree1 :: BinTree1 a -> Int
heightBinTree2 :: BinTree2 a -> Int

heightBinTree3 :: BinTree3 a -> Int
heightBinTree3 Emp3 = 0
heightBinTree3 (Node3 _ t1 t2) = 1 + max (heightBinTree2 t1) (heightBinTree2 t2)
{% endhighlight %}

However, the memory representation of some values aren't the most efficient. The general memory representations of our `BinTree<n>`s would look something like:

{:.text-align-center}
`BinTree3`
![BinTree3 Emp3 memory layout](/assets/bin-tree-mem3-emp.svg){:width="15%"}
![BinTree2 Node3 memory layout](/assets/bin-tree-mem3-node.svg){:width="50%"}

{:.text-align-center}
`BinTree2`
![BinTree2 Emp2 memory layout](/assets/bin-tree-mem2-emp.svg){:width="15%"}
![BinTree2 Node2 memory layout](/assets/bin-tree-mem2-node.svg){:width="50%"}

{:.text-align-center}
`BinTree1`
![BinTree1 Emp1 memory layout](/assets/bin-tree-mem1-emp.svg){:width="15%"}
![BinTree1 Leaf memory layout](/assets/bin-tree-mem1-leaf.svg){:width="20%"}

If we have empty subtrees at any point, we are bloating our representation with extra 0s. The following examples are have 2 empty subtrees in a `Node<n>` at some point, which produces the following memory layouts:

{% highlight haskell %}
ex1 :: a -> BinTree3 a
ex1 a = Node3 a Emp2 Emp2

ex2 :: a -> a -> BinTree3 a
ex2 a1 a2 = Node3 a1 (Node2 a2 Emp1 Emp1) Emp2
{% endhighlight %}

{:.text-align-center}
`ex1`
![BinTree3 ex1 memory layout](/assets/bin-tree-ex1.svg){:width="30%"}

{:.text-align-center}
`ex2`
![BinTree3 ex2 memory layout](/assets/bin-tree-ex2.svg){:width="50%"}

The only reason for the trailing 0s in the above example is to indicate that there is no more useful information. If we had trees of some much large depth, then we could have lots of trailing 0s holding essentially no information! A shorter way to store the information that we're truncating the tree here is by an extra tag at the start to say whether any more information is held.

Some binary tree structures explicitly encode this fact into their data type via leaves:

{% highlight haskell %}
data BinTree3' a = Emp3' | Leaf3' a | Node3' a (BinTree2' a) (BinTree2' a)
data BinTree2' a = Emp2' | Leaf2' a | Node2' a (BinTree1 a) (BinTree1 a)
{% endhighlight %}

Now we can explicitly say that at any point that there's no subtrees and no extra information to read other than the given `a`. Our examples from earlier can be expressed much more succintly:

{% highlight haskell %}
ex1' :: a -> BinTree3' a
ex1' a = Leaf3' a

ex2' :: a -> a -> BinTree3' a
ex2' a1 a2 = Node3' a1 (Leaf2' a2) Emp2'
{% endhighlight %}

With smaller memory layouts:

However, our height functions now have to explicitly handle the `Leaf<n>'` cases:

{% highlight haskell %}
heightBinTree2' :: BinTree2' a -> Int

heightBinTree' :: BinTree3' a -> Int
heightBinTree' Emp3' = 0
heightBinTree' (Leaf3' _) = 1
heightBinTree' (Node3' _ t1 t2) = 1 + max (heightBinTree2' t1) (heightBinTree2' t2)
{% endhighlight %}

In more complicated functions, it might be difficult to verify that we're treating `Leaf<n>' a`s the same as `Node<n>' a Emp<n-1>' Emp<n-1>'`.

Wouldn't it be nice to be able to code with the first binary tree, yet still reap the efficiency benefits of the leaf representation?

## Back to algebra

Let's take a look at the "sum" and "product" algebraic view of our `BinTree3` and `BinTree3'` types.

{% highlight text %}
BinTree1 a = 1 + a
BinTree2 a = 1 + (a * (BinTree1 a) * (BinTree1 a))
BinTree3 a = 1 + (a * (BinTree2 a) * (BinTree2 a))

BinTree2' a = 1 + a + (a * (BinTree1 a) * (BinTree1 a))
BinTree3' a = 1 + a + (a * (BinTree2' a) * (BinTree2' a))
{% endhighlight %}

If this was regular algebra on the integers (i.e. a commutative semi-ring or rig) then we could substitute the definitions, rearrange the sums and expand the multiplication on brackets (distribute), like

{% highlight text %}
a * (b + c) = (a * b) + (a * c)
{% endhighlight %}

But why not? Do data types indeed act like a commutative semi-ring? What does "act like" mean in this context?

TODO: create topic on this and have multiple blog posts
TODO: finish off this one and publish

