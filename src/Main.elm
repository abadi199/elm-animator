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
    { notificationState : Animator.State Bool
    , kind : Bool -> Animator.Kind
    }


type Msg
    = UserClickTestButton
    | UserClickCloseNotificationButton
    | NotificationStateChange (Animator.State Bool)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { notificationState = Animator.initialState False
      , kind =
            \showNotification ->
                if showNotification then
                    Animator.SlideInFromTop

                else
                    Animator.Fade
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


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
                , justifyContent center
                , flexDirection column
                , position relative
                ]
            ]
            [ H.button
                [ HA.type_ "button"
                , HE.onClick UserClickTestButton
                , HA.css
                    [ padding2 (em 1) (em 2)
                    , fontWeight bold
                    , borderRadius (px 5)
                    ]
                ]
                [ H.text "Test" ]
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
                    [ viewNotification <| Animator.toState <| model.notificationState ]
                    model.notificationState
                    |> Animator.withKind model.kind
                    |> Animator.withStateChangeHandler NotificationStateChange
                    |> Animator.toHtml
                ]
            ]
        ]
            |> List.map H.toUnstyled
    }


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
                , margin4 (em 2) (em 1) (em 1) (em 1)
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
                    , padding2 (px 5) (px 10)
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
            ( { model
                | notificationState = model.notificationState |> Animator.transitioning True
              }
            , Cmd.none
            )

        UserClickCloseNotificationButton ->
            ( { model
                | notificationState = model.notificationState |> Animator.transitioning False
              }
            , Cmd.none
            )

        NotificationStateChange notificationState ->
            ( { model | notificationState = notificationState }
            , Cmd.none
            )
