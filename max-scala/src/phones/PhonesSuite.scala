package phones

import org.scalatest.FunSuite

class PhonesSuite extends FunSuite {
  test("letterToDigit") {
    assert(Phones.letterToDigit('A') === '2')
    assert(Phones.letterToDigit('B') === '2')
    assert(Phones.letterToDigit('Z') === '9')
  }

  test("wordToNumber") {
    assert(Phones.wordToNumber("aaa") === "222")
    assert(Phones.wordToNumber("a") === "2")
    assert(Phones.wordToNumber("scala") === "72252")
  }

  test("numberToWords") {
    assert(Phones("aaa", "aab", "abc", "ddd", "eee").numberToWords ===
      Map("222" -> List("aaa", "aab", "abc"), "333" -> List("ddd", "eee")))
  }

  test("encodings") {
    assert(Phones("aa", "dd", "cd").encodings("23") === Vector("cd"))
    assert(Phones("a", "b", "d").encodings("23") === Vector("a d", "b d"))
    assert(Phones("a", "d", "ad").encodings("23") === Vector("a d", "ad"))
  }

  test("encodings example") {
    val encodings = Phones().encodings("63263379355")
    assert(encodings.length === 57)
    assert(encodings.contains("me codes well"))
  }
}
