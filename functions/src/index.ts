import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {randomUUID} from 'crypto';

const region = 'europe-west1';

admin.initializeApp();

const validatePayload = (payload: Payload) => {
  if (!payload?.userId || typeof payload.userId != 'string') {
    throw new functions.https.HttpsError('invalid-argument',
      'userId is invalid');
  }
};

const validateJoinGamePayload = (payload: JoinGamePayload) => {
  validatePayload(payload);
  if (!payload?.data?.gameId || typeof payload?.data?.gameId != 'string') {
    throw new functions.https.HttpsError('invalid-argument',
      'gameId is invalid');
  }
};

export const generateUserId = functions
  .region(region)
  .https.onCall(async () => {
    return randomUUID();
  });
export const createGame = functions
  .region(region)
  .https.onCall(async (payload: Payload) => {
    validatePayload(payload);

    // enough unique lol, finished games are going to be deleted anyway.
    const gameId = Math.floor(100000 + Math.random() * 900000);

    const gameState: GameState = {
      userId: payload.userId,
      adminUserId: payload.userId,
      status: GameStatus.LOBBY,
      gameId, members: [{
        userId: payload.userId,
        name: '_UNSET_',
        isAdmin: true,
      },
      ],
    };

    const gameModel: GameModel = {
      adminUserId: gameState.userId,
      status: gameState.status,
      gameId, members:
      gameState.members,
    };

    // TODO: check if game with same ID does not exist, generate new ID otherwise.
    await admin.database().ref('/games').child(gameId + '').set(gameModel)
      .catch((reason) => {
        console.error('createGame', reason);
        throw new functions.https.HttpsError('unknown',
          'An unknown error occurred.');
      });

    return gameState;
  });
export const joinGame = functions
  .region(region)
  .https.onCall(async (payload: JoinGamePayload) => {
    validateJoinGamePayload(payload);

    const gameSnap = await admin.database().ref(`/games/${payload.data.gameId}`).get();

    if (!gameSnap.exists()) {
      throw new functions.https.HttpsError('not-found',
        `Game with ID ${payload.data.gameId} does not exist`);
    }


    const membersRef = gameSnap.ref.child('/members');
    const membersSnap = await membersRef.get();
    const members: MembersModel = membersSnap.val();

    // User was not in this game before, adding them as members
    if (!members.find((m) => m.userId == payload.userId)) {
      const newMember: MembersModel = [
        {
          userId: payload.userId,
          name: '_UNSET_',
          isAdmin: false,
        },
      ];
      await membersRef.push(newMember);
    }


    const gameState: GameState = {
      userId: payload.userId,
      adminUserId: gameSnap.val().adminUserId,
      gameId: gameSnap.val().gameId,
      status: gameSnap.val().status,
      members: (await membersRef.get()).val(),
    };

    return gameState;
  });
