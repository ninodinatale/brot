/**
 * Data Models
 */
type Game = {
    key: string,
    gameCode: string,
    adminUserId: string,
    status: GameStatus
}

enum GameStatus {
    lobby,
    scoreBoard,
    choosingBread,
    votingWords,
    playing
}

type Member = {
    key: string,
    userId: string,
    name: string,
    isAdmin: boolean,
    isBread: boolean,
    hasVotedForWord: boolean,
    points: number,
};
type MemberCreate =
    Omit<Member, 'key' | 'hasVotedForWord' | 'points' | 'isBread' | 'name'>
type Word = {
  key: string,
  userId: string,
  gameKey: string,
  value: string,
  votes: number,

}

/**
 * Responses
 */
type CommonGameResponse = {
    gameKey: string,
    memberKey: string
}
type CreateGameResponse = CommonGameResponse;
type JoinGameResponse = CommonGameResponse;

/**
 * Payloads
 */
type Payload<T = Record<string, string>> = T
type CreateGamePayload = Payload<UserId>
type JoinGamePayload = Payload<UserId & GameCode>
type ChooseBreadPayload = Payload<UserId & GameKey>
type VoteWordPayload = Payload<UserId & GameKey & WordKey>
type GetGamePayload = Payload<GameKey>
type StartGamePayload = Payload<UserId & GameKey>
type GetMemberPayload = Payload<GameKey & MemberKey>

type UserId = {
    userId: string
}
type WordKey = {
    wordKey: string
}
type GameKey = {
    gameKey: string
}
type MemberKey = {
    memberKey: string
}
type GameCode = {
    gameCode: string
}

export {
  Member,
  Game,
  Word,
  GameStatus,
  MemberCreate,
  CreateGamePayload,
  JoinGamePayload,
  ChooseBreadPayload,
  VoteWordPayload,
  GetGamePayload,
  StartGamePayload,
  GetMemberPayload,
  CreateGameResponse,
  JoinGameResponse,
};
