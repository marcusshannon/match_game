import { Socket } from 'phoenix';

const socket = new Socket('/socket', { params: { token: window.token } });

socket.connect();

export default socket;
