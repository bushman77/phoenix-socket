module Phoenix.Message exposing (Msg(..), mapAll, none, channelSuccessfullyJoined, channelFailedToJoin, cmdMap)

import Json.Decode as Decode
import Phoenix.Channel exposing (Channel)


type Msg msg
    = NoOp
    | ExternalMsg msg
    | ChannelSuccessfullyJoined (Channel msg) Decode.Value
    | ChannelFailedToJoin (Channel msg) Decode.Value


mapAll : (Msg msg -> msg) -> Msg msg -> msg
mapAll fn internalMsg =
    case internalMsg of
        ExternalMsg msg ->
            msg

        _ ->
            fn internalMsg

cmdMap : (Msg msg -> msg) -> Cmd msg ->  Cmd msg
cmdMap fn internalMsg =
    internalMsg

none : Msg msg
none =
    NoOp


channelSuccessfullyJoined : Channel msg -> Decode.Value -> Msg msg
channelSuccessfullyJoined channel response =
    ChannelSuccessfullyJoined channel response


channelFailedToJoin : Channel msg -> Decode.Value -> Msg msg
channelFailedToJoin channel response =
    ChannelFailedToJoin channel response
