class Cons[+A](hd: A, tl: => MyStream[A]) extends MyStream[A] {
  override def isEmpty: Boolean = false
  override val head: A = hd
  override lazy val tail: MyStream[A] = tl
  override def #::[B >: A](elem: B): MyStream[B] =
    new Cons[B](elem, this)

  override def ++[B >: A](anotherStream: => MyStream[B]): MyStream[B] =
    new Cons[B](head, tail ++ anotherStream)

  override def foreach(f: A => Unit): Unit = {
    f(head)
    tail.foreach(f)
  }
}