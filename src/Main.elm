module Main exposing (main)

import Animator
import Browser
import Css exposing (..)
import Css.Reset as Reset
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes as HA
import Html.Styled.Events as HE


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { showNotification : Bool
    , page : Page
    }


type Page
    = PageOne
    | PageTwo
    | PageThree


type Msg
    = UserClickTestButton
    | UserClickCloseNotificationButton
    | UserClickPageOneButton
    | UserClickPageTwoButton
    | UserClickPageThreeButton


init : () -> ( Model, Cmd Msg )
init _ =
    ( { showNotification = False
      , page = PageOne
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


buttonStyle : List Style
buttonStyle =
    [ padding2 (em 1) (em 2)
    , fontWeight bold
    , borderRadius (px 5)
    ]


view : Model -> Browser.Document Msg
view model =
    { title = "Animator Demo"
    , body =
        [ Reset.meyerV2
        , Reset.borderBoxV201408
        , H.div
            [ HA.css
                [ width (vw 100)
                , height (vh 100)
                , displayFlex
                , alignItems center
                , justifyContent flexEnd
                , flexDirection column
                , position relative
                ]
            ]
            [ Animator.animator
                [ case model.page of
                    PageOne ->
                        viewOne

                    PageTwo ->
                        viewTwo

                    PageThree ->
                        viewThree
                ]
                |> Animator.withKind
                    (case model.page of
                        PageOne ->
                            Animator.SlideFromLeft

                        PageTwo ->
                            Animator.SlideFromRight

                        PageThree ->
                            Animator.SlideFromTop
                    )
                |> Animator.toHtml
            , H.div
                [ HA.css
                    [ displayFlex
                    , alignItems spaceBetween
                    , paddingTop (em 1)
                    , paddingBottom (em 1)
                    ]
                ]
                [ H.button
                    [ HA.type_ "button"
                    , HA.css (marginRight (em 1) :: buttonStyle)
                    , HE.onClick UserClickPageOneButton
                    ]
                    [ H.text "1" ]
                , H.button
                    [ HA.type_ "button"
                    , HA.css (marginRight (em 1) :: buttonStyle)
                    , HE.onClick UserClickPageTwoButton
                    ]
                    [ H.text "2" ]
                , H.button
                    [ HA.type_ "button"
                    , HA.css (marginRight (em 1) :: buttonStyle)
                    , HE.onClick UserClickPageThreeButton
                    ]
                    [ H.text "3" ]
                , H.button
                    [ HA.type_ "button"
                    , HE.onClick UserClickTestButton
                    , HA.css buttonStyle
                    ]
                    [ H.text "Show Notification" ]
                ]
            , H.p
                [ HA.css
                    [ displayFlex
                    , position absolute
                    , flexDirection column
                    , alignItems center
                    , top zero
                    , width (vw 100)
                    ]
                ]
                [ Animator.animator
                    [ viewNotification model.showNotification ]
                    |> Animator.withKind
                        (if model.showNotification then
                            Animator.SlideFromTop

                         else
                            Animator.SlideFromBottom
                        )
                    |> Animator.toHtml
                ]
            ]
        ]
            |> List.map H.toUnstyled
    }


viewOne : H.Html msg
viewOne =
    H.node "view-one"
        [ HA.css
            [ width (pct 100)
            , height (pct 100)
            , displayFlex
            , justifyContent center
            , alignItems center
            , backgroundColor (hex "#FFB7B2")
            ]
        ]
        [ H.h1 [] [ H.text "One" ] ]


viewTwo : H.Html msg
viewTwo =
    H.node "view-two"
        [ HA.css
            [ width (pct 100)
            , height (pct 100)
            , displayFlex
            , justifyContent center
            , alignItems center
            , backgroundColor (hex "#E2F0CB")
            ]
        ]
        [ H.h1 [] [ H.text "Two" ] ]


viewThree : H.Html msg
viewThree =
    H.node "view-three"
        [ HA.css
            [ width (pct 100)
            , height (pct 100)
            , displayFlex
            , justifyContent center
            , alignItems center
            , backgroundColor (hex "#C7CEEA")
            ]
        ]
        [ H.h1 [] [ H.text "Three" ] ]


viewNotification : Bool -> H.Html Msg
viewNotification flag =
    if flag then
        H.div
            [ HA.css
                [ backgroundColor (rgba 252 129 129 1)
                , fontWeight bold
                , fontFamily sansSerif
                , padding (em 1)
                , borderRadius (px 5)
                , margin4 (em 2) auto (em 1) auto
                , maxWidth (px 500)
                , property "box-shadow"
                    "2px 2px 5px rgba(0,0,0,0.25)"
                , boxSizing contentBox
                , displayFlex
                , flexDirection row
                , justifyContent spaceBetween
                , alignItems center
                ]
            ]
            [ H.span [] [ H.text "Warning - This is a test!!!" ]
            , H.button
                [ HA.type_ "button"
                , HA.css
                    [ border zero
                    , backgroundColor (rgba 0 0 0 0.25)
                    , fontWeight bold
                    , padding2 (px 15) (px 20)
                    ]
                , HE.onClick UserClickCloseNotificationButton
                ]
                [ H.text "CLOSE" ]
            ]

    else
        H.text ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserClickTestButton ->
            ( { model | showNotification = True }
            , Cmd.none
            )

        UserClickCloseNotificationButton ->
            ( { model | showNotification = False }
            , Cmd.none
            )

        UserClickPageOneButton ->
            ( { model | page = PageOne }, Cmd.none )

        UserClickPageTwoButton ->
            ( { model | page = PageTwo }, Cmd.none )

        UserClickPageThreeButton ->
            ( { model | page = PageThree }, Cmd.none )
