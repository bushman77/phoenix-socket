module Phoenix exposing (listen, update, join, push, initPushWithChannelName)

{-|
# Basic Usage

@docs listen, update, join, push, initPushWithChannelName
-}

import Phoenix.Socket as Socket exposing(Socket)
import Phoenix.Channel as Channel exposing(Channel)
import Phoenix.Message as Message exposing(Msg)
import Phoenix.Push as Push exposing(Push)

{-|
What t?
-}
listen : (Msg msg -> msg) -> Socket msg ->  Sub msg
listen toExternalAppMsgFn socket  =
    Socket.listen socket toExternalAppMsgFn


{-|
update
-}
update: (Msg msg -> msg) -> Msg msg -> Socket msg -> (Socket msg, Cmd msg)
update toExternalAppMsgFn msg socket =
    Socket.update toExternalAppMsgFn msg socket

{-|
join
-}
join: (Msg msg -> msg) -> Channel msg -> Socket msg -> (Socket msg, Cmd msg)
join toExternalAppMsgFn channel socket =
    let
        (updateSocket, phxCmd) = Socket.join channel socket
    in
       (updateSocket, Cmd.map toExternalAppMsgFn phxCmd)

{-|
push
-}
push: (Msg msg -> msg) -> Push msg -> Socket msg -> (Socket msg, Cmd msg)
push toExternalAppMsgFn pushRecord socket =
    let
        (updateSocket, phxCmd) = Socket.push pushRecord socket
    in
       (updateSocket, Cmd.map toExternalAppMsgFn phxCmd)



{-| initPushWithChannelName
-}
initPushWithChannelName: String -> String -> Socket msg -> Maybe (Push msg)
initPushWithChannelName event channelName socket =
    socket.channels
    |> Channel.findChannel channelName
    |> Maybe.andThen(\chan -> Just (Push.init event chan))
