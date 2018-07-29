module Phoenix.Internal.SocketHelper exposing (..)

import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.ChannelHelper as ChannelHelper
import Phoenix.Message as Message exposing (Msg(..))
import Phoenix.Event as Event exposing (Event)
import WebSocket as NativeWebSocket
import Json.Encode as Encode

import Dict

mapMaybeInternalEvents :  Dict.Dict String (Channel msg)  -> Maybe Event -> Msg msg
mapMaybeInternalEvents channels maybeEvent =
    case maybeEvent of
        Just event ->
            mapInternalEvents channels event

        Nothing ->
            Message.none


mapInternalEvents :  Dict.Dict String (Channel msg)  -> Event -> Msg msg
mapInternalEvents channels event =
    let
        channel =
            Channel.findChannel event.topic
    in
        case event.event of
            "phx_reply" ->
                handleInternalPhxReply channels event

            "phx_close" ->
                channels
                    |> channel
                    |> Maybe.andThen (\chan -> Just (Message.channelClosed event.payload chan))
                    |> Maybe.withDefault Message.none

            "phx_error" ->
                channels
                    |> channel
                    |> Maybe.andThen (\chan -> Just (Message.channelError event.payload chan))
                    |> Maybe.withDefault Message.none

            _ ->
                Message.none



mapMaybeExternalEvents :  Dict.Dict String (Channel msg)  -> Maybe Event -> Msg msg
mapMaybeExternalEvents channels maybeEvent =
    case maybeEvent of
        Just event ->
            mapExternalEvents channels event

        Nothing ->
            Message.none


mapExternalEvents :  Dict.Dict String (Channel msg)  -> Event -> Msg msg
mapExternalEvents channels event =
    let
        channelWithRef =
            Channel.findChannelWithRef event.topic event.ref

        channel =
            Channel.findChannel event.topic
    in
        case event.event of
            "phx_reply" ->
                case channelWithRef channels of
                    Just chan ->
                        case Event.decodeReply event.payload of
                            Ok response ->
                                ChannelHelper.onJoinedCommand response chan

                            Err response ->
                                ChannelHelper.onFailedToJoinCommand response chan

                    Nothing ->
                        Message.none

            "phx_error" ->
                channels
                    |> channelWithRef
                    |> Maybe.andThen (\chan -> Just (ChannelHelper.onErrorCommand event.payload chan))
                    |> Maybe.withDefault Message.none

            "phx_close" ->
                channels
                    |> channelWithRef
                    |> Maybe.andThen (\chan -> Just (ChannelHelper.onClosedCommand event.payload chan))
                    |> Maybe.withDefault Message.none

            -- phx_join phx_leave
            _ ->
                channels
                    |> channel
                    |> Maybe.andThen (\chan -> Just (ChannelHelper.onCustomCommand event.event event.payload chan))
                    |> Maybe.withDefault Message.none

handleInternalPhxReply :  Dict.Dict String (Channel msg)  -> Event -> Msg msg
handleInternalPhxReply channels event =
    case Channel.findChannelWithRef event.topic event.ref channels of
        Just channel ->
            case Event.decodeReply event.payload of
                Ok response ->
                    Message.channelSuccessfullyJoined channel response

                Err response ->
                    Message.channelFailedToJoin channel response

        Nothing ->
            Message.none

