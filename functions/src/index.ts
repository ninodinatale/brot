import {initializeApp} from 'firebase/app';
import {https, logger, region} from 'firebase-functions';
import {
  DataSnapshot,
  equalTo,
  get,
  getDatabase,
  increment,
  orderByChild,
  push,
  query,
  ref,
  set,
  update,
} from 'firebase/database';
import {
  ChooseBreadPayload,
  CreateGamePayload,
  CreateGameResponse,
  Game,
  GameStatus,
  GetGamePayload,
  GetMemberPayload,
  JoinGamePayload,
  JoinGameResponse,
  Member,
  MemberCreate,
  StartGamePayload,
  VoteWordPayload,
} from './types';

const EUROPE_WEST_ = 'europe-west1';

const app = initializeApp({
  // only used for local unit testing
  projectId: 'who-is-the-bread',
});
export const db = getDatabase(app);

/**
 * @return {Promise<number>} generated game code.
 */
export async function generateGameCode() {
  let gameCode = '';
  while (gameCode === '') {
    // enough unique lol, finished games are going to be deleted anyway.
    const potentialGameCode =
            (100000 + Math.floor(Math.random() * 899999)).toString();

    const snap = await get(query(ref(db, 'games'), orderByChild('gameCode'), equalTo(potentialGameCode)));

    if (!snap.exists()) {
      gameCode = potentialGameCode;
    }
  }
  return gameCode;
}

/**
 Creates a game and joins it.

 Returns the key of the created game.
 **/
export const createGame =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: CreateGamePayload): Promise<CreateGameResponse> => {
          validateCreateGamePayload(payload);
          logger.info('creating game for user with id %s', payload.userId);
          const gameCode = await exports.generateGameCode();

          logger.info(`game code will be ${gameCode}`);


          const newGameRef = await push(ref(db, 'games'));
          const newGame: Game = {
            key: newGameRef.key!,
            gameCode: gameCode,
            adminUserId: payload.userId,
            status: GameStatus.lobby,
          };

          await set(newGameRef, newGame);

          logger.log('game %o created', newGame);
          const member = await createMember(newGameRef.key!, {
            userId: payload.userId,
            isAdmin: true,
          });

          return {gameKey: newGame.key, memberKey: member.key};
        });

export const joinGame =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: JoinGamePayload): Promise<JoinGameResponse> => {
          validateJoinGamePayload(payload);
          logger.info('try joining game with code %s for user with id %s',
              payload.gameCode, payload.userId);
          const gameSnap = await get(query(ref(db, 'games'), orderByChild('gameCode'), equalTo(payload.gameCode)));

          if (!gameSnap.exists()) {
            logger.info('game with code %s does not exist, returning error',
                payload.gameCode);
            throw new https.HttpsError('not-found', `game with code
             ${payload.gameCode} not found`);
          }

          const game = Object.values(gameSnap.val())[0] as Game;

          if (game.status !== GameStatus.lobby) {
            logger.info(`game ${game} has already started, cannot join`);
            throw new https.HttpsError('invalid-argument',
                `game with code ${payload.gameCode} already started`);
          }


          const gameKey = game.key;
          const gameMembersRef = ref(db, `members/${gameKey}`);
          const existingMemberSnap = await get(query(gameMembersRef, orderByChild('userId'), equalTo(payload.userId)));

          let memberKey: string;
          if (!existingMemberSnap.exists()) {
            memberKey = (await createMember(gameKey,
                {userId: payload.userId, isAdmin: false})).key;
          } else {
            memberKey = (Object.values(gameSnap.val())[0] as Member).key;
            logger.info('user already exists as member; nothing to do');
          }
          return {gameKey, memberKey};
        });

export const chooseBread =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: ChooseBreadPayload): Promise<void> => {
          validateChooseBreadPayload(payload);
          logger.info('choosing bread for game %o with user %s',
              payload.gameKey, payload.userId);

          const game = (await _getGame(payload.gameKey)).val() as Game;

          validateGameStatus(game.status, GameStatus.choosingBread);

          const gameMembersSnap = await get(ref(db, `members/${game.key}`));
          validateSnapshotExists(gameMembersSnap);

          await set(ref(db, `/games/${payload.gameKey}/status`), GameStatus.choosingBread);

          const allMembers = [] as Member[];
          gameMembersSnap.forEach((memberSnap) => {
            allMembers.push(memberSnap.val());
          });

          // artificial wait time
          await setTimeout(async () => {
            const randomIndex = Math.floor(Math.random() * allMembers.length);
            const breadMember = allMembers[randomIndex];
            await set(ref(db, `/members/${game.key}/${breadMember.key}/isBread`), true);
            await set(ref(db, `/games/${game.key}/status`), GameStatus.votingWords);
          }, 5000);
        });

export const voteWord =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: VoteWordPayload): Promise<void> => {
          validateVoteWordPayload(payload);
          logger.info(`userId ${payload.userId} voting for word ${payload.wordKey}`);

          const game = (await _getGame(payload.gameKey)).val() as Game;

          validateGameStatus(game.status, GameStatus.votingWords);

          const userMemberSnap = await get(query(ref(db, `/members/${payload.gameKey}`), orderByChild('userId'), equalTo(payload.userId)));

          const userMember = Object.values(userMemberSnap.val())[0] as Member;


          if (userMemberSnap.exists() && userMember.hasVotedForWord) {
            logger.error(`user ${payload.userId} already voted for word ${payload.wordKey}`);
            throw new https.HttpsError('internal',
                'user has already voted for word');
          }

          const updates: { [path: string]: unknown } = {};
          updates[`/words/${payload.gameKey}/${payload.wordKey}/votes`] = increment(1);
          updates[`/members/${payload.gameKey}/${userMember.key}/hasVotedForWord`] = true;
          await update(ref(db), updates);
        });

export const startGame =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: StartGamePayload): Promise<void> => {
          validateStartGamePayload(payload);
          const game: Game = (await _getGame(payload.gameKey)).val();
          validateGameStatus(game.status, GameStatus.lobby);
          await set(ref(db, `/games/${payload.gameKey}/status`), GameStatus.scoreBoard);
        });

export const getGame =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: GetGamePayload): Promise<Game> => {
          validateGetGamePayload(payload);
          return (await _getGame(payload.gameKey)).val();
        });

export const getMember =
    region(EUROPE_WEST_)
        .https
        .onCall(async (payload: GetMemberPayload): Promise<Game> => {
          validateGetMemberPayload(payload);
          return (await _getMember(payload.gameKey, payload.memberKey)).val();
        });


/**
 * Getting game from DB
 * @param {string} gameKey
 */
async function _getGame(gameKey: string): Promise<DataSnapshot> {
  const gameSnap = await get(ref(db, `/games/${gameKey}`));
  validateSnapshotExists(gameSnap);
  return gameSnap;
}

/**
 * Getting member of game from DB
 * @param {string} gameKey
 * @param {string} memberKey
 */
async function _getMember(gameKey: string, memberKey: string): Promise<DataSnapshot> {
  const memberSnap = await get(ref(db, `/members/${gameKey}/${memberKey}`));
  validateSnapshotExists(memberSnap);
  return memberSnap;
}

/**
 * Validates game status
 * @param {GameStatus} currentStatus
 * @param {GameStatus} expectedStatus
 */
function validateGameStatus(currentStatus: GameStatus, expectedStatus: GameStatus): void {
  if (currentStatus !== expectedStatus) {
    logger.error('game has wrong status');
    throw new https.HttpsError('internal',
        'game has wrong status');
  }
}

/**
 * @param {DataSnapshot} snap
 */
function validateSnapshotExists(snap: DataSnapshot) {
  if (!snap.exists()) {
    throwError(`snapshot with path ${snap.ref.toString()} not found`);
  }
}

/**
 *
 * @param {string} msg
 */
function throwError(msg: string) {
  logger.error(msg);
  throw new https.HttpsError('internal', msg);
}

/**
 * ValidatePayload
 */
class ValidatePayload {
  /**
   * @param {any} payload
   */
  static userId(payload: any) {
    if (!payload?.userId || typeof payload.userId != 'string') {
      throw new https.HttpsError('invalid-argument',
          'payload is invalid');
    }
  }
  /**
     * @param {any} payload
     */
  static gameCode(payload: any) {
    if (!payload?.gameCode || typeof payload.gameCode != 'string') {
      throw new https.HttpsError('invalid-argument',
          'payload is invalid');
    }
  }
  /**
     * @param {any} payload
     */
  static gameKey(payload: any) {
    if (!payload?.gameKey || typeof payload.gameKey != 'string') {
      throw new https.HttpsError('invalid-argument',
          'payload is invalid');
    }
  }
  /**
     * @param {any} payload
     */
  static memberKey(payload: any) {
    if (!payload?.memberKey || typeof payload.memberKey != 'string') {
      throw new https.HttpsError('invalid-argument',
          'payload is invalid');
    }
  }

  /**
   * @param {any} payload
   */
  static wordKey(payload: any) {
    if (!payload?.wordKey || typeof payload.wordKey != 'string') {
      throw new https.HttpsError('invalid-argument',
          'payload is invalid');
    }
  }
}


const validateCreateGamePayload = (payload: CreateGamePayload) => {
  ValidatePayload.userId(payload);
};


const validateJoinGamePayload = (payload: JoinGamePayload) => {
  ValidatePayload.userId(payload);
  ValidatePayload.gameCode(payload);
};

const validateGetGamePayload = (payload: GetGamePayload) => {
  ValidatePayload.gameKey(payload);
};

const validateStartGamePayload = (payload: StartGamePayload) => {
  ValidatePayload.userId(payload);
  ValidatePayload.gameKey(payload);
};

const validateGetMemberPayload = (payload: GetMemberPayload) => {
  ValidatePayload.gameKey(payload);
  ValidatePayload.memberKey(payload);
};

const validateChooseBreadPayload = (payload: ChooseBreadPayload) => {
  ValidatePayload.userId(payload);
  ValidatePayload.gameKey(payload);
};

const validateVoteWordPayload = (payload: VoteWordPayload) => {
  ValidatePayload.userId(payload);
  ValidatePayload.gameKey(payload);
  ValidatePayload.wordKey(payload);
};

/**
 *
 * Creates a member with the passed [gameMemberRef] and returns the created
 * member as a [Member] instance.
 *
 * As a side effect, stores the game key locally to know if the user is
 * currently in a game without querying the db.
 * @param {string} gameKey
 * @param {MemberCreate} memberToCreate
 * @return {Promise<Member>}
 */
async function createMember(gameKey: string, memberToCreate: MemberCreate):
    Promise<Member> {
  logger.info('creating member');
  const newMemberRef =
        push(ref(db, `/members/${gameKey}`));

  const member: Member = {
    key: newMemberRef.key!,
    name: '',
    hasVotedForWord: false,
    isBread: false,
    points: 0,
    ...memberToCreate,
  };
  await set(newMemberRef, member);
  logger.info('member %o created', member);

  return member;
}

