module Language.Xml exposing (suite)

import Result exposing (Result(..))
import Expect exposing (Expectation, equal, onFail)
import Fuzz exposing (string)
import Test exposing (..)
import Parser
import SyntaxHighlight.Language.Type as T exposing (Syntax(..))
import SyntaxHighlight.Language.Xml as Xml exposing (Syntax(..), toRevTokens)


suite : Test
suite =
    describe "Xml Language Test Suite"
        [ equalTest "Element" "<p class=\"hero\">Hero</p>" <|
            Ok [ ( Normal, "<" ), ( C Tag, "p" ), ( Normal, " " ), ( C Attribute, "class" ), ( Normal, "=" ), ( C AttributeValue, "\"" ), ( C AttributeValue, "hero" ), ( C AttributeValue, "\"" ), ( Normal, ">Hero" ), ( Normal, "</" ), ( C Tag, "p" ), ( Normal, ">" ) ]
        , equalTest "Comment" "<script>\n<!-- comment\n-->\n</script" <|
            Ok [ ( Normal, "<" ), ( C Tag, "script" ), ( Normal, ">" ), ( LineBreak, "\n" ), ( Comment, "<!--" ), ( Comment, " comment" ), ( LineBreak, "\n" ), ( Comment, "-->" ), ( LineBreak, "\n" ), ( Normal, "</" ), ( C Tag, "script" ) ]
        , equalTest "Incomplete tag" "<html" <|
            Ok [ ( Normal, "<" ), ( C Tag, "html" ) ]
        , equalTest "Incomplete comment" "<!-- comment" <|
            Ok [ ( Comment, "<!--" ), ( Comment, " comment" ) ]
        , equalTest "Incomplete attribute" "<div class" <|
            Ok [ ( Normal, "<" ), ( C Tag, "div" ), ( Normal, " " ), ( C Attribute, "class" ) ]
        , equalTest "Incomplete attribute 2" "<div class =" <|
            Ok [ ( Normal, "<" ), ( C Tag, "div" ), ( Normal, " " ), ( C Attribute, "class" ), ( Normal, " " ), ( Normal, "=" ) ]
        , fuzz string "Fuzz string" <|
            \fuzzStr ->
                Xml.toRevTokens fuzzStr
                    |> Result.map
                        (List.reverse
                            >> List.map Tuple.second
                            >> String.concat
                        )
                    |> equal (Ok fuzzStr)
                    |> onFail ("Resulting error string: \"" ++ fuzzStr ++ "\"")
        ]


equalTest : String -> String -> Result Parser.Error (List ( T.Syntax Xml.Syntax, String )) -> Test
equalTest testName testStr testResult =
    describe testName
        [ test "Syntax equality" <|
            \() ->
                Xml.toRevTokens testStr
                    |> Result.map List.reverse
                    |> equal testResult
        , test "String equality" <|
            \() ->
                Xml.toRevTokens testStr
                    |> Result.map
                        (List.reverse
                            >> List.map Tuple.second
                            >> String.concat
                        )
                    |> equal (Ok testStr)
        ]
