'use strict';
const path = require('path');
const {promisify} = require('util');
const childProcess = require('child_process');

const execFile = promisify(childProcess.execFile);
const bin = path.join(__dirname, '../bin/ActiveWinHelper');

const parseMac = stdout => {
	try {
		const result = JSON.parse(stdout);
		if (result !== null) {
			result.platform = 'macos';
			return result;
		}

		return {error: 'platform was not macos'};
	} catch (error) {
		console.error(stdout);
		console.error(error);
		return {error};
	}
};

module.exports = async () => {
	const {error, stdout} = await execFile(bin, ['getActiveWin'], {encoding: 'utf8'});
	if (error) {
		console.error(`error returned ${JSON.stringify(error)} ${stdout}`);
		return {error};
	}

	return parseMac(stdout);
};

module.exports.sync = () => {
	try {
		const stdout = childProcess.execFileSync(bin, ['getActiveWin'], {encoding: 'utf8'});
		return parseMac(stdout);
	} catch (error) {
		console.error(`error returned ${JSON.stringify(error)}`);
		return {error};
	}
};
