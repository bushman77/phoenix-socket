module Phoenix.Internal.Message exposing (InternalMessage(..), channelClosed, channelError, channelFailedToJoin, channelSuccessfullyJoined, none)

import Http
import Json.Decode as Decode
import Phoenix.Channel exposing (Channel)
import Phoenix.Event exposing (Event)
import Time exposing (Time)


type InternalMessage msg
    = NoOp
    | ChannelSuccessfullyJoined (Channel msg) Decode.Value
    | ChannelFailedToJoin (Channel msg) Decode.Value
    | ChannelClosed (Channel msg) Decode.Value
    | ChannelError (Channel msg) Decode.Value
    | HeartbeatReply
    | Heartbeat Time


channelSuccessfullyJoined : Channel msg -> Decode.Value -> InternalMessage msg
channelSuccessfullyJoined channel response =
    ChannelSuccessfullyJoined channel response


channelFailedToJoin : Channel msg -> Decode.Value -> InternalMessage msg
channelFailedToJoin channel response =
    ChannelFailedToJoin channel response


none : InternalMessage msg
none =
    NoOp


channelClosed : Decode.Value -> Channel msg -> InternalMessage msg
channelClosed response channel =
    ChannelClosed channel response


channelError : Decode.Value -> Channel msg -> InternalMessage msg
channelError response channel =
    ChannelError channel response
