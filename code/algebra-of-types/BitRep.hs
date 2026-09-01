module BitRep where
  import Data.List

  data Bit = Zero | One

  class BitRep a where
    toBinary :: a -> List Bit

  -- Binary tree of depth at most 3 
  data BinTree3 a = Emp3 | Node3 a (BinTree2 a) (BinTree2 a) -- 1 + (a * below * below)
  data BinTree2 a = Emp2 | Node2 a (BinTree1 a) (BinTree1 a) -- 1 + (a * below * below)
  data BinTree1 a = Emp1 | Leaf a -- 1 + a
  -- =
  -- 1 + a + 2a^2 + 5a^3 + 6a^4 + 6a^5 + 4a^6 + a^7


  -- Calculate height
  heightBinTree :: BinTree3 a -> Int
  heightBinTree Emp3 = 0
  heightBinTree (Node3 _ t1 t2) = 1 + max (heightBinTree2 t1) (heightBinTree2 t2)
    where
      heightBinTree2 :: BinTree2 a -> Int
      heightBinTree2 Emp2 = 0
      heightBinTree2 (Node2 _ Emp1 Emp1) = 1
      heightBinTree2 (Node2 _ _ _) = 2

  -- Not too complicated (we could gen all the BinTreens with template haskell)

  ex1 :: a -> BinTree3 a
  ex1 a = Node3 a Emp2 Emp2

  ex2 :: a -> a -> BinTree3 a
  ex2 a1 a2 = Node3 a1 (Node2 a2 Emp1 Emp1) Emp2

  -- Binary tree with leaves of depth at most 2
  data BinTree3' a = Emp3' | Leaf3' a | Node3' a (BinTree2' a) (BinTree2' a) -- 1 + a + (a * below * below) 
  data BinTree2' a = Emp2' | Leaf2' a | Node2' a (BinTree1 a) (BinTree1 a) -- 1 + a + (a * (1 + a) * (1 + a))
  -- =
  -- 1 + a

  ex1' :: a -> BinTree3' a
  ex1' a = Leaf3' a

  ex2' :: a -> a -> BinTree3' a
  ex2' a1 a2 = Node3' a1 (Leaf2' a2) Emp2'

  heightBinTree' :: BinTree3' a -> Int
  heightBinTree' Emp3' = 0
  heightBinTree' (Leaf3' _) = 1
  heightBinTree' (Node3' _ t1 t2) = 1 + max (heightBinTree2' t1) (heightBinTree2' t2)
    where
      heightBinTree2' :: BinTree2' a -> Int
      heightBinTree2' Emp2' = 0
      heightBinTree2' (Leaf2' _) = 1
      -- Same as Leaf
      heightBinTree2' (Node2' _ Emp1 Emp1) = 1
      heightBinTree2' (Node2' _ _ _) = 2


