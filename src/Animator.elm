module Animator exposing
    ( Kind(..)
    , animator
    , onFinish
    , toHtml
    , withKind
    )

import Css exposing (..)
import Html.Styled as H
import Html.Styled.Attributes as HA


type Animator msg
    = Animator (Data msg)


type alias Data msg =
    { kind : Kind
    , content : List (H.Html msg)
    , onFinish : Maybe msg
    }


type Kind
    = SlideFromTop
    | SlideFromLeft
    | SlideFromBottom
    | SlideFromRight
    | Fade
    | NoAnimation


kindToString : Kind -> String
kindToString kind =
    case kind of
        SlideFromLeft ->
            "SlideFromLeft"

        SlideFromRight ->
            "SlideFromRight"

        SlideFromBottom ->
            "SlideFromBottom"

        SlideFromTop ->
            "SlideFromTop"

        Fade ->
            "Fade"

        NoAnimation ->
            "NoAnimation"


animator :
    List (H.Html msg)
    -> Animator msg
animator content =
    Animator
        { kind = Fade
        , content = content
        , onFinish = Nothing
        }


toHtml : Animator msg -> H.Html msg
toHtml (Animator data) =
    H.node "elm-animator"
        [ HA.css
            [ overflow hidden
            , width (pct 100)
            , height (pct 100)
            , property "display" "grid"
            , property "grid-template-areas" "\"content\""
            ]
        , HA.attribute "elm-animator-kind" (kindToString <| data.kind)
        ]
        [ H.node "elm-animator-content"
            []
            (List.map (H.toUnstyled >> H.fromUnstyled) data.content)
        ]


withKind : Kind -> Animator msg -> Animator msg
withKind kind (Animator data) =
    Animator { data | kind = kind }


onFinish : msg -> Animator msg -> Animator msg
onFinish msg (Animator data) =
    Animator { data | onFinish = Just msg }
