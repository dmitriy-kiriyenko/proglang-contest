package phones

import scala.io.Source

object Main {
  def main(args: Array[String]) {
    val phones = Phones()
    for (number <- Source.stdin.getLines; enc <- phones.encodings(number))
      println(number + " " + enc)
  }
}
