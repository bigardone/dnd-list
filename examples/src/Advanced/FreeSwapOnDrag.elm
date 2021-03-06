module Advanced.FreeSwapOnDrag exposing (Model, Msg, initialModel, main, source, subscriptions, update, view)

import Browser
import Browser.Events
import DnDList
import Html
import Html.Attributes
import Html.Events
import Html.Keyed
import Json.Decode



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- DATA


type alias KeyedItem =
    ( String, String )


data : List KeyedItem
data =
    List.range 1 9
        |> List.map (\i -> ( "key-" ++ String.fromInt i, String.fromInt i ))



-- SYSTEM


config : DnDList.Config Msg
config =
    { message = MyMsg
    , movement = DnDList.Free DnDList.Swap DnDList.OnDrag
    }


system : DnDList.System Msg KeyedItem
system =
    DnDList.create config



-- MODEL


type alias Model =
    { draggable : DnDList.Draggable
    , items : List KeyedItem
    , affected : List Int
    }


initialModel : Model
initialModel =
    { draggable = system.draggable
    , items = data
    , affected = []
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ system.subscriptions model.draggable
        , if model.affected == [] then
            Sub.none

          else
            Browser.Events.onMouseDown
                (Json.Decode.succeed ClearAffected)
        ]



-- UPDATE


type Msg
    = MyMsg DnDList.Msg
    | ClearAffected


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MyMsg message ->
            let
                ( draggable, items ) =
                    system.update message model.draggable model.items

                ( maybeDragIndex, maybeDropIndex ) =
                    ( system.dragIndex draggable, system.dropIndex draggable )

                affected : List Int
                affected =
                    case ( maybeDragIndex, maybeDropIndex ) of
                        ( Just dragIndex, Just dropIndex ) ->
                            if dragIndex /= dropIndex then
                                dragIndex :: dropIndex :: []

                            else
                                model.affected

                        _ ->
                            model.affected
            in
            ( { model | draggable = draggable, items = items, affected = affected }
            , system.commands model.draggable
            )

        ClearAffected ->
            ( { model | affected = [] }, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
        maybeDragIndex : Maybe Int
        maybeDragIndex =
            system.dragIndex model.draggable
    in
    Html.section
        [ Html.Attributes.style "margin" "6em 0" ]
        [ model.items
            |> List.indexedMap (itemView model.affected maybeDragIndex)
            |> Html.Keyed.node "div" containerStyles
        , draggedItemView model.draggable model.items
        ]


itemView : List Int -> Maybe Int -> Int -> KeyedItem -> ( String, Html.Html Msg )
itemView affected maybeDragIndex index ( key, item ) =
    let
        styles : List (Html.Attribute Msg)
        styles =
            itemStyles
                ++ (if List.member index affected then
                        affectedItemStyles

                    else
                        []
                   )
    in
    case maybeDragIndex of
        Just dragIndex ->
            if dragIndex /= index then
                ( key
                , Html.div
                    (styles ++ system.dropEvents index)
                    [ Html.text item ]
                )

            else
                ( key
                , Html.div (itemStyles ++ placeholderItemStyles) []
                )

        Nothing ->
            let
                itemId : String
                itemId =
                    "id-" ++ item
            in
            ( key
            , Html.div
                (Html.Attributes.id itemId :: styles ++ system.dragEvents index itemId)
                [ Html.text item ]
            )


draggedItemView : DnDList.Draggable -> List KeyedItem -> Html.Html Msg
draggedItemView draggable items =
    let
        maybeDraggedItem : Maybe KeyedItem
        maybeDraggedItem =
            system.dragIndex draggable
                |> Maybe.andThen (\index -> items |> List.drop index |> List.head)
    in
    case maybeDraggedItem of
        Just ( _, item ) ->
            Html.div
                (itemStyles ++ draggedItemStyles ++ system.draggedStyles draggable)
                [ Html.text item ]

        Nothing ->
            Html.text ""



-- STYLES


containerStyles : List (Html.Attribute msg)
containerStyles =
    [ Html.Attributes.style "display" "grid"
    , Html.Attributes.style "grid-template-columns" "5em 5em 5em"
    , Html.Attributes.style "grid-template-rows" "5em 5em 5em"
    , Html.Attributes.style "grid-gap" "5em"
    , Html.Attributes.style "justify-content" "center"
    ]


itemStyles : List (Html.Attribute msg)
itemStyles =
    [ Html.Attributes.style "background" "#aa1e9d"
    , Html.Attributes.style "border-radius" "8px"
    , Html.Attributes.style "color" "white"
    , Html.Attributes.style "cursor" "pointer"
    , Html.Attributes.style "font-size" "1.2em"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    ]


draggedItemStyles : List (Html.Attribute msg)
draggedItemStyles =
    [ Html.Attributes.style "background" "#1e9daa" ]


placeholderItemStyles : List (Html.Attribute msg)
placeholderItemStyles =
    [ Html.Attributes.style "background" "dimgray" ]


affectedItemStyles : List (Html.Attribute msg)
affectedItemStyles =
    [ Html.Attributes.style "background" "#691361" ]



-- SOURCE


source : String
source =
    """
module FreeSwapOnDrag exposing (main)

import Browser
import Browser.Events
import DnDList
import Html
import Html.Attributes
import Html.Events
import Html.Keyed
import Json.Decode



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- DATA


type alias KeyedItem =
    ( String, String )


data : List KeyedItem
data =
    List.range 1 9
        |> List.map (\\i -> ( "key-" ++ String.fromInt i, String.fromInt i ))



-- SYSTEM


config : DnDList.Config Msg
config =
    { message = MyMsg
    , movement = DnDList.Free DnDList.Swap DnDList.OnDrag
    }


system : DnDList.System Msg KeyedItem
system =
    DnDList.create config



-- MODEL


type alias Model =
    { draggable : DnDList.Draggable
    , items : List KeyedItem
    , affected : List Int
    }


initialModel : Model
initialModel =
    { draggable = system.draggable
    , items = data
    , affected = []
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ system.subscriptions model.draggable
        , if model.affected == [] then
            Sub.none

          else
            Browser.Events.onMouseDown
                (Json.Decode.succeed ClearAffected)
        ]



-- UPDATE


type Msg
    = MyMsg DnDList.Msg
    | ClearAffected


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MyMsg message ->
            let
                ( draggable, items ) =
                    system.update message model.draggable model.items

                ( maybeDragIndex, maybeDropIndex ) =
                    ( system.dragIndex draggable, system.dropIndex draggable )

                affected : List Int
                affected =
                    case ( maybeDragIndex, maybeDropIndex ) of
                        ( Just dragIndex, Just dropIndex ) ->
                            if dragIndex /= dropIndex then
                                dragIndex :: dropIndex :: []

                            else
                                model.affected

                        _ ->
                            model.affected
            in
            ( { model | draggable = draggable, items = items, affected = affected }
            , system.commands model.draggable
            )

        ClearAffected ->
            ( { model | affected = [] }, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
        maybeDragIndex : Maybe Int
        maybeDragIndex =
            system.dragIndex model.draggable
    in
    Html.section
        [ Html.Attributes.style "margin" "6em 0" ]
        [ model.items
            |> List.indexedMap (itemView model.affected maybeDragIndex)
            |> Html.Keyed.node "div" containerStyles
        , draggedItemView model.draggable model.items
        ]


itemView : List Int -> Maybe Int -> Int -> KeyedItem -> ( String, Html.Html Msg )
itemView affected maybeDragIndex index ( key, item ) =
    let
        styles : List (Html.Attribute Msg)
        styles =
            itemStyles
                ++ (if List.member index affected then
                        affectedItemStyles

                    else
                        []
                   )
    in
    case maybeDragIndex of
        Just dragIndex ->
            if dragIndex /= index then
                ( key
                , Html.div
                    (styles ++ system.dropEvents index)
                    [ Html.text item ]
                )

            else
                ( key
                , Html.div (itemStyles ++ placeholderItemStyles) []
                )

        Nothing ->
            let
                itemId : String
                itemId =
                    "id-" ++ item
            in
            ( key
            , Html.div
                (Html.Attributes.id itemId :: styles ++ system.dragEvents index itemId)
                [ Html.text item ]
            )


draggedItemView : DnDList.Draggable -> List KeyedItem -> Html.Html Msg
draggedItemView draggable items =
    let
        maybeDraggedItem : Maybe KeyedItem
        maybeDraggedItem =
            system.dragIndex draggable
                |> Maybe.andThen (\\index -> items |> List.drop index |> List.head)
    in
    case maybeDraggedItem of
        Just ( _, item ) ->
            Html.div
                (itemStyles ++ draggedItemStyles ++ system.draggedStyles draggable)
                [ Html.text item ]

        Nothing ->
            Html.text ""



-- STYLES


containerStyles : List (Html.Attribute msg)
containerStyles =
    [ Html.Attributes.style "display" "grid"
    , Html.Attributes.style "grid-template-columns" "5em 5em 5em"
    , Html.Attributes.style "grid-template-rows" "5em 5em 5em"
    , Html.Attributes.style "grid-gap" "5em"
    , Html.Attributes.style "justify-content" "center"
    ]


itemStyles : List (Html.Attribute msg)
itemStyles =
    [ Html.Attributes.style "background" "#aa1e9d"
    , Html.Attributes.style "border-radius" "8px"
    , Html.Attributes.style "color" "white"
    , Html.Attributes.style "cursor" "pointer"
    , Html.Attributes.style "font-size" "1.2em"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    ]


draggedItemStyles : List (Html.Attribute msg)
draggedItemStyles =
    [ Html.Attributes.style "background" "#1e9daa" ]


placeholderItemStyles : List (Html.Attribute msg)
placeholderItemStyles =
    [ Html.Attributes.style "background" "dimgray" ]


affectedItemStyles : List (Html.Attribute msg)
affectedItemStyles =
    [ Html.Attributes.style "background" "#691361" ]
    """
