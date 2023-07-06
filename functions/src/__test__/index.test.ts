import firebaseFunctionsTest from 'firebase-functions-test';
import * as testee from '../index';
import {db, joinGame} from '../index';
import * as chai from 'chai';
import {expect} from 'chai';
import chaiAsPromised from 'chai-as-promised';
import {https, logger} from 'firebase-functions';
import {
  ChooseBreadPayload,
  CreateGamePayload,
  CreateGameResponse,
  Game,
  GameStatus,
  JoinGamePayload,
  Member,
  VoteWordPayload,
  Word,
} from '../types';
import {SinonFakeTimers, stub, useFakeTimers} from 'sinon';
import chaiSubset from 'chai-subset';
import {equalTo, get, orderByChild, query, ref, remove, set, update} from 'firebase/database';


chai.use(chaiSubset);
chai.use(chaiAsPromised);


// Import the exported function definitions from our functions/index.js file
// Initialize the firebase-functions-test SDK using environment variables.
// These variables are automatically set by firebase emulators:exec
//
// This configuration will be used to initialize the Firebase Admin SDK, so
// when we use the Admin SDK in the tests below we can be confident it will
// communicate with the emulators, not production.
const test = firebaseFunctionsTest({
  projectId: process.env.GCLOUD_PROJECT,
});


describe('', () => {
  stub(logger);
  describe('createGame', () => {
    const validPayload: CreateGamePayload = {
      userId: 'member1',
    };

    after(() => {
      test.cleanup();
    });

    describe('if payload is invalid', () => {
      after(() => {
        test.cleanup();
      });

      [
        undefined,
        null,
        {},
        'userId',
        2,
        {userId: undefined},
        {userId: null},
        {userId: {}},
        {userId: 2},
      ].forEach((payload) => {
        it('should throw HttpsError', () => {
          const wrapped = test.wrap(testee.createGame);

          const promise = wrapped(payload);

          expect(promise).to.be.rejectedWith(
              new https.HttpsError('invalid-argument', 'payload is invalid'),
          );
        });
      });
    });

    describe('if payload is valid', () => {
      const generatedGameCode = '111111';

      before(() => {
        stub(testee, 'generateGameCode')
            .returns(Promise.resolve(generatedGameCode));
      });

      beforeEach(async () => {
        await remove(ref(db));
      });

      it('should resolve', async () => {
        const wrapped = test.wrap(testee.createGame);
        const promise: Promise<unknown> = wrapped(validPayload);
        expect(promise).not.to.be.rejected;
      });

      it('should create game in the db', async () => {
        const wrapped = test.wrap(testee.createGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gamesSnap = await get(ref(db, '/games'));

          expect(gamesSnap.exists()).to.be.true;
          expect(gamesSnap.size).equals(1);
        });
      });

      it('should set properties accordingly for a new game', async () => {
        const wrapped = test.wrap(testee.createGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gamesSnap = await get(ref(db, '/games'));

          gamesSnap.forEach((gameSnap) => {
            expect(gameSnap.val()).to.containSubset({
              key: gameSnap.key,
              gameCode: generatedGameCode,
              adminUserId: validPayload.userId,
              status: GameStatus.lobby,
            });
          });
        });
      });

      it('should create a member for the game', async () => {
        const wrapped = test.wrap(testee.createGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gamesSnap = await get(ref(db, '/games'));

          const gameKey = Object.keys(gamesSnap.val())[0];

          const memberSnap = await get(ref(db, `/members/${gameKey}`));
          expect(memberSnap.exists()).to.be.true;
          expect(memberSnap.size).equals(1);
        });
      });

      it('should set properties accordingly ' +
                'for a new member of a new game', async () => {
        const wrapped = test.wrap(testee.createGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gamesSnap = await get(ref(db, '/games'));

          const gameKey = Object.keys(gamesSnap.val())[0];

          const memberSnap =
                        await get(ref(db, `/members/${gameKey}`));
          memberSnap.forEach((memberSnap) => {
            expect(memberSnap.val()).to.containSubset({
              key: memberSnap.key,
              userId: validPayload.userId,
              isAdmin: true,
              name: '',
              hasVotedForWord: false,
              isBread: false,
              points: 0,
            });
          });
        });
      });

      it('should resolve with created key of game and member', async () => {
        const wrapped = test.wrap(testee.createGame);
        const promise: Promise<CreateGameResponse> = wrapped(validPayload);

        return promise.then(async (returnValue: CreateGameResponse) => {
          const gamesSnap = await get(ref(db, '/games'));
          const gameKey = Object.keys(gamesSnap.val())[0];

          const memberSnap =
                        await get(ref(db, `/members/${gameKey}`));
          const memberKey = Object.keys(memberSnap.val())[0];

          expect(returnValue.gameKey).to.equal(gameKey);
          expect(returnValue.memberKey).to.equal(memberKey);
        });
      });
    });
  });

  describe('joinGame', () => {
    const existingGame: Game = {
      key: 'existing_game_key_111111',
      gameCode: '111111',
      status: GameStatus.lobby,
      adminUserId: 'anything',
    };
    const validPayload: JoinGamePayload = {
      userId: 'member1',
      gameCode: existingGame.gameCode,
    };

    beforeEach(async () => {
      await remove(ref(db));
      await update(ref(db, `/games/${existingGame.key}`), existingGame);
    });

    after(() => {
      test.cleanup();
    });

    describe('if payload is invalid', () => {
      after(() => {
        test.cleanup();
      });

      [
        undefined,
        null,
        {},
        'userId',
        2,
        {userId: undefined},
        {userId: null},
        {userId: {}},
        {userId: 2},
        {data: undefined},
        {data: {}},
        {data: 'data'},
        {data: 2},
        {
          data: {
            gameCode: undefined,
          },
        },
        {
          data: {
            gameCode: null,
          },
        },
        {
          data: {
            gameCode: 1,
          },
        },
        {
          data: {
            gameCode: true,
          },
        },
      ].forEach((payload: unknown) => {
        if (typeof payload === 'object') {
          payload = {...validPayload, ...payload};
        }

        it('should throw HttpsError', () => {
          const wrapped = test.wrap(joinGame);

          const promise = wrapped(payload);

          expect(promise).to.be.rejectedWith(
              new https.HttpsError('invalid-argument', 'payload is invalid'),
          );
        });
      });
    });

    describe('if payload is valid', () => {
      it('should resolve', async () => {
        const wrapped = test.wrap(joinGame);
        const promise: Promise<unknown> = wrapped(validPayload);
        expect(promise).not.to.be.rejected;
      });

      it('should create a member for the game', async () => {
        const wrapped = test.wrap(joinGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gameSnap = await get(ref(db, `/games/${existingGame.key}`));

          const memberSnap =
                        await get(ref(db, `/members/${gameSnap.key}`));
          expect(memberSnap.exists()).to.be.true;
          expect(memberSnap.size).equals(1);
        });
      });

      it('should set properties accordingly ' +
                'for a new member of the existing', async () => {
        const wrapped = test.wrap(joinGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gameSnap = await get(ref(db, `/games/${existingGame.key}`));

          const memberSnap =
                        await get(ref(db, `/members/${gameSnap.key}`));
          memberSnap.forEach((memberSnap) => {
            expect(memberSnap.val()).to.containSubset({
              key: memberSnap.key,
              userId: validPayload.userId,
              isAdmin: false,
              name: '',
              hasVotedForWord: false,
              isBread: false,
              points: 0,
            });
          });
        });
      });

      it('should resolve with key of game and member', async () => {
        const wrapped = test.wrap(joinGame);
        const promise: Promise<CreateGameResponse> = wrapped(validPayload);

        return promise.then(async (returnValue: CreateGameResponse) => {
          const gameSnap = await get(ref(db, `/games/${existingGame.key}`));

          const membersSnap =
                        await get(ref(db, `/members/${gameSnap.key}`));

          expect(membersSnap.size).to.eq(1);

          membersSnap.forEach((child) => {
            expect(returnValue.memberKey).to.equal(child.val().key);
          });

          expect(returnValue.gameKey).to.equal(gameSnap.key);
        });
      });
      it('should not create member if ' +
                'member already exists for this game', async () => {
        const existingMember: Member = {
          key: 'existing_member_key',
          name: 'fridolin',
          isAdmin: false,
          userId: validPayload.userId,
          isBread: false,
          hasVotedForWord: false,
          points: 0,
        };

        await set(ref(db, `/members/${existingGame.key}/${existingMember.key}`), existingMember);
        const wrapped = test.wrap(testee.joinGame);
        const promise: Promise<unknown> = wrapped(validPayload);

        return promise.then(async () => {
          const gameSnap = await get(ref(db, `/games/${existingGame.key}`));

          const memberSnap =
                        await get(ref(db, `/members/${gameSnap.key}`));
          expect(memberSnap.size).equals(1);
        });
      });
      it('should throw HttpsError if game does not exist', () => {
        const wrapped = test.wrap(testee.joinGame);
        const payload: JoinGamePayload = {
          ...validPayload,
          gameCode: '222222',
        };

        const promise = wrapped(payload);

        expect(promise).to.be.rejectedWith(https.HttpsError);
      });

      Object.values(GameStatus).forEach((status) => {
        it('should throw HttpsError if game has already started', async () => {
          await set(ref(db, `/games/${existingGame.key}/status`), status);
          const wrapped = test.wrap(testee.joinGame);

          const promise = wrapped(validPayload);

          expect(promise).to.be.rejectedWith(https.HttpsError);
        });
      });
    });
  });

  describe('chooseBread', () => {
    const randomStub = stub(Math, 'random').returns(0.2);
    let clock: SinonFakeTimers;
    const existingGame: Game = {
      key: 'existing_game_key_111111',
      gameCode: '111111',
      status: GameStatus.lobby,
      adminUserId: 'anything',
    };

    const existingMembers: Member[] = [
      {
        key: 'member1',
        name: 'member1',
        isBread: false,
        hasVotedForWord: false,
        isAdmin: false,
        points: 0,
        userId: '',
      },
      {
        key: 'member2',
        name: 'member2',
        isBread: false,
        hasVotedForWord: false,
        isAdmin: false,
        points: 0,
        userId: '',
      },
      {
        key: 'member3',
        name: 'member3',
        isBread: false,
        hasVotedForWord: false,
        isAdmin: false,
        points: 0,
        userId: '',
      },
    ];

    const validPayload: ChooseBreadPayload = {
      userId: 'member1',
      gameKey: existingGame.key,
    };

    before(() => clock = useFakeTimers());
    beforeEach(() => {
      remove(ref(db));
      update(ref(db, `/games/${existingGame.key}`), existingGame);
      for (const value of existingMembers) {
        set(ref(db, `/members/${existingGame.key}/${value.key}`), value);
      }
      clock.tick(100);
    });
    // afterEach(() => clock.restore());

    after(() => {
      test.cleanup();
      randomStub.restore();
      clock.restore();
    });

    describe('if payload is invalid', () => {
      after(() => {
        test.cleanup();
      });

      [
        undefined,
        null,
        {},
        'userId',
        2,
        {userId: undefined},
        {userId: null},
        {userId: {}},
        {userId: 2},
        {data: undefined},
        {data: {}},
        {data: 'data'},
        {data: 2},
        {
          data: {
            gameKey: undefined,
          },
        },
        {
          data: {
            gameKey: null,
          },
        },
        {
          data: {
            gameKey: 1,
          },
        },
        {
          data: {
            gameKey: true,
          },
        },
      ].forEach((payload: unknown) => {
        if (typeof payload === 'object') {
          payload = {...validPayload, ...payload};
        }

        it('should throw HttpsError', () => {
          const wrapped = test.wrap(testee.chooseBread);

          const promise = wrapped(payload);

          expect(promise).to.be.rejectedWith(https.HttpsError);
        });
      });
    });

    describe('if payload is valid', () => {
      it('should resolve', async () => {
        const wrapped = test.wrap(testee.chooseBread);
        const promise: Promise<unknown> = wrapped(validPayload);
        expect(promise).not.to.be.rejected;
      });

      Object.values(GameStatus)
          .filter((status) => status != GameStatus.choosingBread)
          .forEach((status) => {
            it('should throw HttpsError if ' +
                    'game has already started', async () => {
              await set(ref(db, `/games/${existingGame.key}/status`), status);
              const wrapped = test.wrap(testee.chooseBread);

              const promise = wrapped(validPayload);

              expect(promise).to.be.rejectedWith(
                  new https.HttpsError('internal', 'game has wrong status'),
              );
            });
          });

      [
        [0.1922, 0],
        [0.3244422, 0],
        [0.3444422, 1],
        [0.6444422, 1],
        [0.7444422, 2],
        [0.9999999, 2],
      ].forEach(([randomRetVal, expectedIndex]) => {
        it('should have set a member to bread randomly', () => {
          randomStub.returns(randomRetVal);
          const wrapped = test.wrap(testee.chooseBread);
          const promise: Promise<unknown> = wrapped(validPayload);
          promise.then(async () => {
            const membersSnap = await get(ref(db, `/members/${existingGame.key}`));

            const members: Member[] = [];
            membersSnap.forEach((snap) => {
              members.push(snap.val());
            });

            members.forEach((value, index) => {
              if (index == expectedIndex) {
                expect(value.isBread).to.be.true;
              } else {
                expect(value.isBread).to.be.false;
              }
            });
          });
          clock.tick(5001);
        });
      });
      it('should set game status to choosing bread', () => {
        const wrapped = test.wrap(testee.chooseBread);
        const promise: Promise<unknown> = wrapped(validPayload);
        promise.then(async () => {
          const gameSnap = await get(ref(db, `/games/${existingGame.key}`));
          expect(gameSnap.val().status).to.eq(GameStatus.choosingBread);
        });
        clock.tick(4000);
      });
    });
  });

  describe('voteWord', () => {
    const existingGame: Game = {
      key: 'existing_game_key_111111',
      gameCode: '111111',
      status: GameStatus.votingWords,
      adminUserId: 'anything',
    };

    const existingMembers: Member[] = [
      {
        key: 'member1',
        name: 'member1',
        isBread: false,
        hasVotedForWord: false,
        isAdmin: false,
        points: 0,
        userId: 'member1',
      },
      {
        key: 'member2',
        name: 'member2',
        isBread: false,
        hasVotedForWord: false,
        isAdmin: false,
        points: 0,
        userId: 'member2',
      },
      {
        key: 'member3',
        name: 'member3',
        isBread: false,
        hasVotedForWord: false,
        isAdmin: false,
        points: 0,
        userId: 'member3',
      },
    ];

    const existingWord: Word = {
      gameKey: existingGame.key,
      key: 'word_key_111111',
      userId: 'anything',
      value: 'haus',
      votes: 0,
    };

    const validPayload: VoteWordPayload = {
      userId: 'member1',
      gameKey: existingGame.key,
      wordKey: existingWord.key,
    };

    beforeEach(async () => {
      await remove(ref(db));
      await set(ref(db, `/games/${existingGame.key}`), existingGame);
      await set(ref(db, `/words/${existingGame.key}/${existingWord.key}`), existingWord);

      for (const value of existingMembers) {
        await set(ref(db, `/members/${existingGame.key}/${value.key}`), value);
      }
    });

    after(() => {
      test.cleanup();
    });

    describe('if payload is invalid', () => {
      after(() => {
        test.cleanup();
      });

      [
        undefined,
        null,
        {},
        'userId',
        2,
        {userId: undefined},
        {userId: null},
        {userId: {}},
        {userId: 2},
        {data: undefined},
        {data: {}},
        {data: 'data'},
        {data: 2},
        {
          data: {
            gameKey: undefined,
            wordKey: '1234567890',
          },
        },
        {
          data: {
            gameKey: null,
            wordKey: '1234567890',
          },
        },
        {
          data: {
            gameKey: 1,
            wordKey: '1234567890',
          },
        },
        {
          data: {
            gameKey: true,
            wordKey: '1234567890',
          },
        },
        {
          data: {
            gameKey: '1234567890',
            wordKey: undefined,
          },
        },
        {
          data: {
            gameKey: '1234567890',
            wordKey: null,
          },
        },
        {
          data: {
            gameKey: '1234567890',
            wordKey: 1,
          },
        },
        {
          data: {
            gameKey: '1234567890',
            wordKey: true,
          },
        },
      ].forEach((payload: unknown) => {
        if (typeof payload === 'object') {
          payload = {...validPayload, ...payload};
        }

        it('should throw HttpsError', () => {
          const wrapped = test.wrap(testee.chooseBread);

          const promise = wrapped(payload);

          expect(promise).to.be.rejectedWith(https.HttpsError);
        });
      });
    });

    describe('if payload is valid', () => {
      it('should resolve', async () => {
        const wrapped = test.wrap(testee.voteWord);
        const promise: Promise<unknown> = wrapped(validPayload);
        expect(promise).not.to.be.rejected;
      });

      Object.values(GameStatus)
          .filter((status) => status != GameStatus.votingWords)
          .forEach((status) => {
            it('should throw HttpsError if ' +
                    'game has already started', async () => {
              await set(ref(db, `/games/${existingGame.key}/status`), status);
              const wrapped = test.wrap(testee.voteWord);

              const promise = wrapped(validPayload);

              expect(promise).to.be.rejectedWith(
                  new https.HttpsError('internal', 'game has wrong status'),
              );
            });
          });
      it('should throw HttpsError if user has already voted', async () => {
        const wrapped = test.wrap(testee.voteWord);

        const okPromise = wrapped(validPayload);
        await okPromise;
        const rejectPromise = wrapped(validPayload);

        expect(rejectPromise).to.be.rejectedWith(
            new https.HttpsError('internal', 'user has already voted for word'),
        );
      });
      it('should increase votes of word by 1', async () => {
        const wrapped = test.wrap(testee.voteWord);
        const promise = wrapped(validPayload);
        await promise;
        return get(ref(db, `/words/${existingGame.key}/${existingWord.key}`)).then((word) => {
          expect(word.val().votes).to.eq(1);
        });
      });
      it('should increase votes of word by 3', async () => {
        const wrapped = test.wrap(testee.voteWord);
        const promise1 = wrapped(validPayload);
        const promise2 = wrapped(validPayload);
        const promise3 = wrapped(validPayload);
        await Promise.all([promise1, promise2, promise3]);
        return get(ref(db, `/words/${existingGame.key}/${existingWord.key}`)).then((word) => {
          expect(word.val().votes).to.eq(3);
        });
      });
      it('should set hasVotedForWord to true', async () => {
        const wrapped = test.wrap(testee.voteWord);
        const promise = wrapped(validPayload);
        await promise;

        const votedMember = await get(query(ref(db, `/members/${existingGame.key}`), orderByChild('userId'), equalTo(validPayload.userId)));

        votedMember.forEach((member) => {
          expect(member.val().hasVotedForWord).to.be.true;
        });
      });
    });
  });
})
;
