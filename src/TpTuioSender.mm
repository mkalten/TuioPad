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

#include "TpTuioSender.h"

void TpTuioSender::touchPressed(int touchId, float x, float y, float w, float h, float a) {
	myCursor[touchId].x	= x;
	myCursor[touchId].y	= y;
	myCursor[touchId].w	= w;
	myCursor[touchId].h	= h;
	myCursor[touchId].a	= a;
	myCursor[touchId].isAlive = true;
}

void TpTuioSender::touchDragged(int touchId, float x, float y, float w, float h, float a) {
	myCursor[touchId].x	= x;
	myCursor[touchId].y	= y;
	myCursor[touchId].w	= w;
	myCursor[touchId].h	= h;
	myCursor[touchId].a	= a;
	myCursor[touchId].isAlive = true;
	myCursor[touchId].moved	= true;
}

void TpTuioSender::touchReleased(int touchId, float x, float y, float w, float h, float a) {
	myCursor[touchId].x	= x;
	myCursor[touchId].y	= y;
	myCursor[touchId].w	= w;
	myCursor[touchId].h	= h;
	myCursor[touchId].a	= a;
	myCursor[touchId].isAlive = false;
}

bool TpTuioSender::setup(std::string host, int port, int tcp, std::string ip, bool blobs) {
	//if(this->host.compare(host) == 0 && this->port == port) return;
	
	do_blobs = blobs;
	if(verbose) printf("TpTuioSender::setup(host: %s, port: %i\n", host.c_str(), port);

	if (tcp==1) {
		try { oscSender = new TcpSender((char*)host.c_str(), port); }
		catch (std::exception e) { return false; }
	} else if (tcp==2) oscSender = new TcpSender(port);
	else oscSender = new UdpSender((char*)host.c_str(), port);
	
	tuioServer = new TuioServer(oscSender);
	tuioServer->enableObjectProfile(false);
	tuioServer->enableBlobProfile(do_blobs);
	tuioServer->setSourceName( "TuioPad",ip.c_str());
	currentTime = TuioTime::getSessionTime();
	return true;
}

void TpTuioSender::close() {
	if(tuioServer) {
		delete tuioServer;
		tuioServer = NULL;
	}
}

void TpTuioSender::update() {
	if(tuioServer == NULL) return;
	
	currentTime = TuioTime::getSessionTime();
	tuioServer->initFrame(currentTime);
	for(int i=0; i<OF_MAX_TOUCHES; i++) {
		
		float x = myCursor[i].x;
		float y = myCursor[i].y;
		float w = myCursor[i].w;
		float h = myCursor[i].h;
		float a = myCursor[i].a;
		
		if(myCursor[i].isAlive && !myCursor[i].wasAlive) {
			if(verbose) printf("TpTuioSender - addTuioCursor %i %f, %f\n", i, x, y);
			tuioCursor[i] = tuioServer->addTuioCursor(x, y);
			if (do_blobs) {
				if(verbose) printf("TpTuioSender - addTuioBlob %i %f, %f, %f, %f, %f, %f\n", i, x, y, a, w, h, w*h);
				tuioBlob[i] = tuioServer->addTuioBlob(x, y, a, w, h, w*h);
				tuioBlob[i]->setSessionID(tuioCursor[i]->getSessionID());
			}
			
		} else if(!myCursor[i].isAlive && myCursor[i].wasAlive) {
			if(verbose) printf("TpTuioSender - removeTuioCursor %i %f, %f\n", i, x, y);
			
			if(tuioCursor[i]) tuioServer->removeTuioCursor(tuioCursor[i]);
			else printf("** WEIRD: Trying to remove tuioCursor %i but it's null\n", i);
			
			if (do_blobs) {
				if(verbose) printf("TpTuioSender - removeTuioBlob %i %f, %f, %f, %f, %f, %f\n", i, x, y, a, w, h, w*h);
				if(tuioBlob[i]) tuioServer->removeTuioBlob(tuioBlob[i]);
				else printf("** WEIRD: Trying to remove tuioBlob %i but it's null\n", i);
			}
			
		} else if(myCursor[i].isAlive && myCursor[i].wasAlive && myCursor[i].moved) {
			myCursor[i].moved = false;
			if(verbose) printf("TpTuioSender - updateTuioCursor %i %f, %f\n", i, x, y);
			if(tuioCursor[i]) tuioServer->updateTuioCursor(tuioCursor[i], x, y);
			else printf("** WEIRD: Trying to update tuioCursor %i but it's null\n", i);
			
			if (do_blobs) {
				if(verbose) printf("TpTuioSender - removeTuioBlob %i %f, %f, %f, %f, %f, %f\n", i, x, y, a, w, h, w*h);
				if(tuioBlob[i]) tuioServer->updateTuioBlob(tuioBlob[i], x, y, a, w, h, w*h);
				else printf("** WEIRD: Trying to update tuioBlob %i but it's null\n", i);
			}
		}
		
		myCursor[i].wasAlive = myCursor[i].isAlive;
	}
	
	tuioServer->stopUntouchedMovingCursors();
	if (do_blobs) tuioServer->stopUntouchedMovingBlobs();
	tuioServer->commitFrame();
}





