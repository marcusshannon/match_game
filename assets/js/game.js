import ReactDOM from 'react-dom';
import React, { Component } from 'react';
import socket from './socket';
import moment from 'moment';

const tileClassName = tile => {
  switch (tile) {
    case 1:
      return 'bg-red';
    case 2:
      return 'bg-blue';
    case 3:
      return 'bg-purple';
    case 4:
      return 'bg-green';
    case 5:
      return 'bg-yellow';
  }
};

const calculateTime = (startTime, time) => {
  if (!time) {
    time = Math.floor(Date.now() / 1000);
  }
  const endTime = startTime + 120;
  return moment
    .max(
      moment()
        .startOf('hour')
        .add(endTime - time, 'seconds'),
      moment().startOf('hour'),
    )
    .format('m:ss');
};

class Game extends Component {
  state = { current_state: 'LOADING' };

  componentDidMount() {
    this.channel = socket.channel(`game:${window.game}`, {});
    this.channel.join().receive('ok', res =>
      this.setState(prevState => ({
        ...prevState,
        ...res,
        tile1: null,
      })),
    );
    this.channel.on('update', res => this.setState(res));
  }

  componentDidUpdate(prevProps, prevState) {
    if (
      prevState.current_state !== 'GAME' &&
      this.state.current_state == 'GAME'
    ) {
      this.state.time = Math.floor(Date.now() / 1000);
      this.timer = setInterval(
        () => this.setState({ time: Math.floor(Date.now() / 1000) }),
        1000,
      );
      this.fetchPlayers(this.state.players);
    }
    if (prevState.players !== this.state.players) {
      this.fetchPlayers(this.state.players);
    }
  }

  fetchPlayers = playerIds =>
    fetch(`/api/fetchUsersById`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json;',
      },
      body: JSON.stringify({ players: playerIds }),
    })
      .then(res => res.json())
      .then(res => this.setState({ playerData: res }));

  handleTileClick = index => {
    const tile1 = this.state.tile1;
    if (tile1 !== null) {
      this.setState({ tile1: null });
      this.channel.push('swap', { tile1, tile2: index });
    } else {
      this.setState({ tile1: index });
    }
  };

  handleStartGame = () => {
    this.channel.push('start');
  };

  render() {
    console.log(this.state);
    if (this.state.start_time + 120 <= this.state.time && this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
    if (this.state.current_state === 'LOADING') {
      return <div>loading...</div>;
    }
    if (this.state.current_state === 'COMPLETE') {
      return (
        <React.Fragment>
          <a href="/">Home</a>
          <h1 className="text-center mt-4 text-indigo">Match 3</h1>
          <h1 className="text-center my-4">0:00</h1>
          <div className="tile-grid p-4 bg-pattern opacity-50">
            {this.state.board.map((tile, index) => (
              <div
                className={`tile rounded-full ${tileClassName(tile)} ${this
                  .state.tile1 === index && 'border-4 border-white'}`}
                key={index}
              />
            ))}
          </div>
          {this.state.playerData && (
            <div>
              <h1 className="text-center text-indigo my-2">Points</h1>
              <div className="flex justify-around flex-wrap px-3">
                {this.state.players.map(player => (
                  <div className="bg-white p-3 rounded shadow my-2">
                    <div className="text-center font-bold mb-2">
                      {this.state.playerData[player].email}
                    </div>
                    <div className="text-xl text-center text-indigo">
                      {this.state.points[player]}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </React.Fragment>
      );
    }
    if (this.state.current_state === 'LOBBY') {
      return (
        <div className="flex justify-center items-center h-full">
          <div className="bg-white rounded p-3 min-w-64 shadow-md">
            <h1 className="text-center mb-2 text-indigo">Lobby</h1>
            <a href="/" className="no-underline text-center mb-2 text-indigo block p-2 border rounded border-indigo">home</a>

            <div>Invite code:</div>
            <pre className="bg-grey-lightest text-lg p-2 text-center font-bold mb-2">
              {window.game}
            </pre>
            <div className="mb-1">Players:</div>
            {this.state.playerData && (
              <div>
                {this.state.players.map(
                  player =>
                    this.state.playerData[player] && (
                      <div className="mb-2" key={player}>
                        {this.state.playerData[player].email}
                      </div>
                    ),
                )}
              </div>
            )}
            {this.state.owner === parseInt(window.user, 10) && (
              <button className="w-full" onClick={this.handleStartGame}>
                Start Game
              </button>
            )}
          </div>
        </div>
      );
    }
    return (
      <React.Fragment>
        <a href="/">Home</a>
        <h1 className="text-center mt-4 text-indigo">Match 3</h1>
        <h1 className="text-center my-4">
          {calculateTime(this.state.start_time, this.state.time)}
        </h1>
        <div className="tile-grid p-4 bg-pattern shadow-inner">
          {this.state.board.map((tile, index) => (
            <div
              className={`tile rounded-full ${tileClassName(tile)} ${this.state
                .tile1 === index && 'border-4 border-white'}`}
              key={index}
              onClick={() => this.handleTileClick(index)}
            />
          ))}
        </div>
        {this.state.playerData && (
          <div>
            <h1 className="text-center text-indigo my-2">Points</h1>
            <div className="flex justify-around flex-wrap px-3">
              {this.state.players.map(player => (
                <div className="bg-white p-3 rounded shadow my-2">
                  <div className="text-center font-bold mb-2">
                    {this.state.playerData[player].email}
                  </div>
                  <div className="text-xl text-center text-indigo">
                    {this.state.points[player]}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </React.Fragment>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById('root'));
