import scala.io.Source

object Phone {
  /* read a file of words */
  val in = Source.fromFile("../dictionary.txt")
  
  /* create a list and filter all words where *all* their characters are not letters (like dashes) */
  val words = in.getLines.toList filter (word => word forall (chr => chr.isLetter))
                                                  
  /* define the map of numbers to letters */
  val nmem = Map( '2' -> "ABC", '3' -> "DEF", '4' -> "GHI", '5' -> "JKL", '6' -> "MNO", '7' -> "PQRS", '8' -> "TUV", '9' -> "WXYZ")
  
  /* invert the map the get a map of letters to digits */
  val charCode: Map[Char, Char] = for ((digit, str) <- nmem; ltr <- str) yield ltr -> digit
  
  /* define a function that returns the numbers of a given word */
  def wordCode(word: String): String = word.toUpperCase map charCode
  
  /* group all words of our long list with the same number */
  val wordsForNum: Map[String, Seq[String]] = words groupBy wordCode withDefaultValue Seq()
  
  /* function that receives a number and finds the words that match it */
  def encode(number: String): Set[List[String]] =
    if (number.isEmpty) Set(List())
    else {
      for {
        split <- 1 to number.length // iterate over the number
        word <- wordsForNum(number take split) // get the word before the spilt
        rest <- encode(number drop split) //get the words after the split
      } yield word :: rest // join the results
    }.toSet // pass a set to the for
 
  /* better print of the results */
  def translate(number: String): Set[String] = encode(number) map (_ mkString " ")
}

object Phones {
  val output = new java.io.PrintWriter("../output.txt")
  def main(args: Array[String]) {
    for {
      number <- Source.fromFile("../input.txt").getLines()
      coding <- Phone.translate(number)
    } output.println(number + " " + coding)  
  }
}
