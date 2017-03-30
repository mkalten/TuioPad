/*
 TuioPad http://www.tuio.org/
 An Open Source TUIO App for iOS based on OpenFrameworks
 (c) 2010-2017 by Mehmet Akten <memo@memo.tv> and Martin Kaltenbrunner <martin@tuio.org>
 
 TuioPad is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 TuioPad is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with TuioPad.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma once

#include "TuioServer.h"
#include "UdpSender.h"
#include "TcpSender.h"
#include "TuioCursor.h"
#include "ofxiOS.h"

#define OF_MAX_TOUCHES 10
using namespace TUIO;

class MyCursorInfo {
public:
	float x, y;
	float w, h, a;
	
	bool isAlive;		// is it alive this frame
	bool wasAlive;		// was it alive this frame
	bool moved;			// did it move this frame
	
	MyCursorInfo() {
		isAlive		= false;
		wasAlive	= false;
		moved		= false;
	}
};

class TpTuioSender {
public:
	bool verbose;
	bool do_blobs;
	OscSender		*oscSender;
	TuioServer		*tuioServer;
	
	TpTuioSender() {
		oscSender	= NULL;
		tuioServer	= NULL;
		//host		= "";
		//port		= 0;
		verbose		= false;
	}
	
	~TpTuioSender() {
		if (tuioServer) delete tuioServer;
		//if (oscSender)  delete oscSender;
	};
	
	bool setup(std::string host, int port, int tcp, std::string ip, bool blobs);
	void update();
	void close();

	void touchPressed(int touchId, float x, float y, float w, float h, float a);
	void touchDragged(int touchId, float x, float y, float w, float h, float a);
	void touchReleased(int touchId, float x, float y, float w, float h, float a);
	
protected:
	//std::string		host;
	//int				port;
	TuioCursor		*tuioCursor[OF_MAX_TOUCHES];
	TuioBlob		*tuioBlob[OF_MAX_TOUCHES];
	MyCursorInfo	myCursor[OF_MAX_TOUCHES];
	TuioTime		currentTime;
};
