declare type MembersModel = { [key: string]: { name: string, isAdmin: boolean } }
declare type GameState = {
    userId: string,
} & GameModel

declare enum GameStatus {
    LOBBY
}

declare type GameModel = {
    adminUserId: string,
    gameId: number,
    status: GameStatus,
    members: MembersModel,
}

declare type Payload = {
    userId: string,
}


declare type JoinGamePayload = Payload & {
    data: {
        gameId: string
    }
}
