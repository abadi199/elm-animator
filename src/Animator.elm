module Animator exposing
    ( Kind(..)
    , State
    , animator
    , initialState
    , toHtml
    , toState
    , transitioning
    , withKind
    , withStateChangeHandler
    )

import Css exposing (..)
import Html.Styled as H
import Html.Styled.Attributes as HA
import Html.Styled.Events as HE
import Json.Decode as JD


type Animator state msg
    = Animator (Data state msg)


type alias Data state msg =
    { kind : state -> Kind
    , content : List (H.Html msg)
    , state : State state
    , stateChangeHandler : Maybe (State state -> msg)
    }


type State state
    = Idle state
    | Transitioning state


initialState : state -> State state
initialState state =
    Idle state


transitioning : state -> State state -> State state
transitioning state _ =
    Transitioning state


type Kind
    = SlideInFromTop
    | Fade
    | NoAnimation


kindToString : Kind -> String
kindToString kind =
    case kind of
        SlideInFromTop ->
            "SlideInFromTop"

        Fade ->
            "Fade"

        NoAnimation ->
            "NoAnimation"


stateToString : State state -> String
stateToString state =
    case state of
        Idle _ ->
            "idle"

        Transitioning _ ->
            "transitioning"


animator :
    List (H.Html msg)
    -> State state
    -> Animator state msg
animator content state =
    Animator
        { kind = always Fade
        , content = content
        , state = state
        , stateChangeHandler = Nothing
        }


toState : State state -> state
toState state =
    case state of
        Idle s ->
            s

        Transitioning s ->
            s


toHtml : Animator state msg -> H.Html msg
toHtml (Animator data) =
    H.node "elm-animator"
        [ HA.css
            [ overflow hidden
            ]
        , HA.attribute "elm-animator-kind" (kindToString <| data.kind <| toState <| data.state)
        , HA.attribute "elm-animator-state" (stateToString data.state)
        , HE.on "elmAnimatorFinish"
            (data.stateChangeHandler
                |> Maybe.map (\stateChangeHandler -> JD.succeed (stateChangeHandler (Idle <| toState data.state)))
                |> Maybe.withDefault (JD.fail "")
            )
        ]
        [ H.node "elm-animator-content" [] data.content
            |> H.toUnstyled
            |> H.fromUnstyled
        ]


withStateChangeHandler : (State state -> msg) -> Animator state msg -> Animator state msg
withStateChangeHandler handler (Animator data) =
    Animator { data | stateChangeHandler = Just handler }


withKind : (state -> Kind) -> Animator state msg -> Animator state msg
withKind kind (Animator data) =
    Animator { data | kind = kind }
