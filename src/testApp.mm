#include "testApp.h"
#define DEBUG

//--------------------------------------------------------------
void testApp::setup(){
    ofxiPhoneDisableIdleTimer();
    ofSetCircleResolution(CIRCLE_SIZE*2);
//    ofSetBackgroundAuto(false); //turn off auto-repaint
    ofSetFrameRate(60);
    ofSetWindowShape(2048, 1536);
//	ofBackground(0, 0, 0);
    
    //set example pdf
    BackgroundImg.loadImage("test_retina.jpg");
    BackgroundImg.update();
//    BackgroundImg.resize(1536 , 2048);
    BackgroundImg.reloadTexture();
    //
    
    for (int i=0; i<10; ++i) {
        touches.push_back(ofPoint(-999, -999, 0));
    }
    
}

//--------------------------------------------------------------
void testApp::update(){
    
    
    leftTouch = ofPoint(-1,-1,0);
    rightTouch = ofPoint(-1,-1,0);
    center = ofPoint(-1,-1,0);
    lEdgeQuarter = ofPoint(-1,-1,0);
    rEdgeQuarter = ofPoint(-1,-1,0);
    
    leftestTouchID = -1;
    rightestTouchID = -1;
    maxDistance = -1;
    angle = -999;
    
    ruler.clear();
    functionIDs.clear();
    nonFunctionIDs.clear();
    buttons.clear();
    pattles.clear();
    
    int touchCount = 0;
    for (int i=0; i<touches.size(); ++i) {
        if( touches[i].x >-1){
            ++touchCount;
            for (int j=0; j<i; ++j) {
                if( touches[j].x >-1){
                    float d = points2distance(touches[i], touches[j]);
                    if(d>maxDistance){
                        leftestTouchID = i;
                        rightestTouchID = j;
                        if(touches[j].x<touches[j].y){
                            leftestTouchID = j;
                            rightestTouchID = i;
                        }
                        maxDistance = d;
                    }
                }
            }
        }
    }
    
    if(maxDistance > RULER_DIST-15 && maxDistance <= RULER_DIST+15){
        if(rulerCountDown>0){
            ++rulerCountDown;
            if(rulerCountDown>RULER_DELAY){
                bRulerOn = true;
                rulerCountDown = 0;
            }
        }
        if(bTouchDown){
            if(!bRulerOn){
                leftRulerID = leftestTouchID;
                rightRulerID = rightestTouchID;
                ++rulerCountDown;
//                bRulerOn = true;
            }
        }
    }else{
        if(rulerCountDown>0){
           rulerCountDown = 0;
        }
        if(touchCount<2){
            if(bRulerOn){
                leftRulerID = -1;
                rightRulerID = -1;
                bRulerOn = false;
            }
        }
    }
    

    if(bRulerOn){
        //update ruler
        leftTouch = touches[leftRulerID];
        rightTouch = touches[rightRulerID];
        ruler.push_back( ofPoint( leftTouch.x-dEdge , leftTouch.y-dUp   , 0) ); //left-upper
        ruler.push_back( ofPoint( rightTouch.x+dEdge, rightTouch.y-dUp  , 0) ); //right-upper
        ruler.push_back( ofPoint( leftTouch.x-dEdge , leftTouch.y+dUp , 0) ); //left-lower
        ruler.push_back( ofPoint( rightTouch.x+dEdge, rightTouch.y+dUp, 0) ); //right-lower
        
        center = ofPoint( (ruler[0].x+ruler[3].x)/2. , (ruler[0].y+ruler[3].y)/2., 0. );
        angle = points2Rad(rightTouch, leftTouch);
        
        pivot = ofPoint((leftTouch.x + rightTouch.x) / 2., (leftTouch.y + rightTouch.y) / 2., 0. );
        
        
        pattles.push_back(ofPoint(pivot.x - PATTLE_SIZE, pivot.y + dUp,0)); //p0
        pattles.push_back(ofPoint(pivot.x, (pivot.y + dUp),0)); //p1, pivot
        pattles.push_back(ofPoint(pivot.x + PATTLE_SIZE, pivot.y + dUp,0));
        pattles.push_back(ofPoint(pivot.x - PATTLE_SIZE/2., pivot.y + sqrt(3.)*PATTLE_SIZE/2. + dUp, 0));
        pattles.push_back(ofPoint(pivot.x + PATTLE_SIZE/2., pivot.y + sqrt(3.)*PATTLE_SIZE/2. + dUp, 0));
        
        
        if(center.x>0){
            ofPoint orig;
            for(int i = 0 ; i < 4; i++){
                if(i == 1 || i == 3){
                    orig = rightTouch;
                }else{
                    orig = leftTouch;
                }
                ofPoint temp = ofPoint( (ruler[i].x-orig.x), (ruler[i].y-orig.y), 0. );
                ofPoint newPoint = ofPoint( temp.x* cos(-angle) - temp.y* sin(-angle),
                                           temp.x* sin(-angle) + temp.y* cos(-angle),
                                           0. );
                ruler[i] = ofPoint((newPoint.x+orig.x), (newPoint.y+orig.y), 0.);
            }
            for(int i = 0; i < 5; i++){
                ofPoint temp = ofPoint((pattles[i].x-pivot.x), (pattles[i].y-pivot.y), 0. );
                ofPoint newPoint = ofPoint( temp.x* cos(-angle) - temp.y* sin(-angle),
                                           temp.x* sin(-angle) + temp.y* cos(-angle),
                                           0. );
                pattles[i] = ofPoint((newPoint.x+pivot.x), (newPoint.y+pivot.y), 0.);
            }
            slope = (ruler[1].y - ruler[0].y)/ (ruler[1].x - ruler[0].x);
            lEdgeCenter = ofPoint( (ruler[0].x+ruler[2].x)/2. , (ruler[0].y+ruler[2].y)/2., 0. );
            rEdgeCenter = ofPoint( (ruler[1].x+ruler[3].x)/2. , (ruler[1].y+ruler[3].y)/2., 0. );
            lEdgeQuarter = ofPoint( (lEdgeCenter.x+ruler[2].x)/2. , (lEdgeCenter.y+ruler[2].y)/2., 0. );
            rEdgeQuarter = ofPoint( (rEdgeCenter.x+ruler[3].x)/2. , (rEdgeCenter.y+ruler[3].y)/2., 0. );
            
            buttons.push_back( ofPoint( lEdgeCenter.x+ 0.35*(rEdgeCenter.x-lEdgeCenter.x), lEdgeCenter.y+ 0.35*(rEdgeCenter.y-lEdgeCenter.y), 0.));
            buttons.push_back( ofPoint( lEdgeCenter.x+ 0.5 *(rEdgeCenter.x-lEdgeCenter.x), lEdgeCenter.y+ 0.5 *(rEdgeCenter.y-lEdgeCenter.y), 0.));
            buttons.push_back( ofPoint( lEdgeCenter.x+ 0.65*(rEdgeCenter.x-lEdgeCenter.x), lEdgeCenter.y+ 0.65*(rEdgeCenter.y-lEdgeCenter.y), 0.));
            
//            pattles.push_back( ofPoint( ruler[2].x+ 0.35*(ruler[3].x-ruler[2].x), ruler[2].y+ 0.35*(ruler[3].y-ruler[2].y), 0.));
//            pattles.push_back( ofPoint( ruler[2].x+ 0.5 *(ruler[3].x-ruler[2].x), ruler[2].y+ 0.5 *(ruler[3].y-ruler[2].y), 0.));
//            pattles.push_back( ofPoint( ruler[2].x+ 0.65*(ruler[3].x-ruler[2].x), ruler[2].y+ 0.65*(ruler[3].y-ruler[2].y), 0.));
            
            
        }
        
        for (int i=0; i<touches.size(); ++i) {
            if(i != leftRulerID && i!=rightRulerID){
                if( touches[i].x >-1){
                    float d1 = points2distance(touches[i], leftTouch);
                    float d2 = points2distance(touches[i], rightTouch);
                    float dToRuler = point2LineDistance(touches[i], lEdgeQuarter, rEdgeQuarter);
                    if( dToRuler < T2D_THLD){
                        if( d1< RULER_DIST && d2< RULER_DIST ){
                            float dRatio = d1 / RULER_DIST;
                            if(dRatio>=0.2 && dRatio<0.8)
                                functionIDs.push_back(i);
                            else
                                nonFunctionIDs.push_back(i);
                        }else{
                            nonFunctionIDs.push_back(i);
                        }
                    }else{
                        nonFunctionIDs.push_back(i);
                    }
                }
            }

        }
    }else{
        touchMode = 0;
        for (int i=0; i<touches.size(); ++i) {
            if( touches[i].x >-1){
                nonFunctionIDs.push_back(i);
            }
        }
    }
    
    //#ifdef DEBUG
//        cout<<bRulerOn<<","<<touchCount<<","<<(maxDistance)<<","<<nonFunctionIDs.size()<<endl;
    //#endif
    if(bTouchDown)  bTouchDown = false;
}


//--------------------------------------------------------------
void testApp::draw(){
    //draw example pdf on screen
    BackgroundImg.draw(0, 0);
    //
    ofNoFill();
    
    for(int i=0; i < linePoints.size(); i+=2){
        //cout << linePoints[i].type << endl;
        if(linePoints[i].type == 1){
            ofSetLineWidth(5);
            ofSetColor(linePoints[i].drawColor);
            ofLine(linePoints[i].position.x,linePoints[i].position.y,linePoints[i+1].position.x,linePoints[i+1].position.y);
            ofSetColor(255);
        }
//        else if(linePoints[i].type == 3){
//            ofSetLineWidth(10);
//            ofSetColor(255);
//            ofLine(linePoints[i].position.x,linePoints[i].position.y,linePoints[i].position.x,linePoints[i].position.y);
//            
//            ofSetColor(255);
//        }
    }
    for (int i = 0; i < curve_count; ++i) {
        for(int j = 0; j < curvePoints[i].size(); ++j){
            if (curvePoints[i][j].type == 1) {
                if((curvePoints[i][j+1].position.x == -1) || (curvePoints[i][j].position.x == -1))
                    break;
                ofSetLineWidth(5);
                ofSetColor(curvePoints[i][j].drawColor);
                ofLine(curvePoints[i][j].position.x,curvePoints[i][j].position.y,curvePoints[i][j+1].position.x,curvePoints[i][j+1].position.y);
                ofSetColor(255);
            }
        }
    }
    
    if(center.x>0){
        
        
//        ofSetPolyMode(OF_POLY_WINDING_NONZERO);
//        ofBeginShape();
//        ofVertex(pattles[0].x, pattles[0].y);
//        ofVertex(pattles[1].x, pattles[1].y);
//        ofVertex(pattles[2].x, pattles[2].y);
//        ofVertex(pattles[4].x, pattles[4].y);
//        ofVertex(pattles[3].x, pattles[3].y);
//        ofEndShape();
        
        ofFill();
        ofSetColor(76);
        ofSetPolyMode(OF_POLY_WINDING_NONZERO);
        ofBeginShape();
        ofVertex(ruler[0].x, ruler[0].y);
        ofVertex(ruler[1].x, ruler[1].y);
        ofVertex(ruler[3].x, ruler[3].y);
        ofVertex(ruler[2].x, ruler[2].y);
        ofEndShape();
        
        

        
//        for (int i = 0; i < ruler.size(); ++i) {
//            cout << i << ":"<< ruler[i] << endl;
//        }
//        for (int i = 0; i < pattles.size(); ++i) {
//            cout << i << ":"<< pattles[i] << endl;
//        }
        
        ofSetColor(255,0,0);
        ofEllipse(buttons[0].x,buttons[0].y, CIRCLE_SIZE*2, CIRCLE_SIZE*2);
       
        ofSetColor(0,255,0);
        ofEllipse(buttons[1].x,buttons[1].y, CIRCLE_SIZE*2, CIRCLE_SIZE*2);
       
        ofSetColor(0,0,255);
        ofEllipse(buttons[2].x,buttons[2].y, CIRCLE_SIZE*2, CIRCLE_SIZE*2);
       
    }
    
    for (int i=0; i<functionIDs.size(); ++i) {
        ofPoint t = touches[functionIDs[i]];
        float dRatio = points2distance(t, leftTouch) / 925;
        float dToRuler = point2LineDistance(touches[functionIDs[i]], lEdgeQuarter, rEdgeQuarter);
        int type = 0;

        if(dToRuler<T2D_THLD){
            if(dRatio>=0.28 && dRatio<0.43) type = 1;
            if(dRatio>=0.43 && dRatio<0.58) type = 2;
            if(dRatio>=0.58 && dRatio<0.73) type = 3;
//            cout<<dRatio<<endl;
            lineStartID = -1;
            tempLineEnd = ofPoint(-1,-1,0);
            
            ofNoFill();
            ofColor(255);
            if(type>0){
                ofCircle(t.x, t.y, CIRCLE_SIZE);
                ofLine(t.x-CIRCLE_SIZE, t.y, t.x+CIRCLE_SIZE, t.y);
                ofLine(t.x, t.y-CIRCLE_SIZE, t.x, t.y+CIRCLE_SIZE);
            }
            ofFill();
            ofSetColor(255);
            switch(type){
                case 1:
                    ofEllipse(buttons[0].x,buttons[0].y, CIRCLE_SIZE*2, CIRCLE_SIZE*2);
                    touchMode = 1;
                    break;
                case 2:
                    ofEllipse(buttons[1].x,buttons[1].y, CIRCLE_SIZE*2, CIRCLE_SIZE*2);
                    touchMode = 2;
                    break;
                case 3:
                    ofEllipse(buttons[2].x,buttons[2].y, CIRCLE_SIZE*2, CIRCLE_SIZE*2);
                    touchMode = 3;
                    break;
                default: break;
            }
            
        }
    }
    
    switch(touchMode){
        case 1:
            ofFill();
            ofSetColor(pickColor);
            break;
        case 2:
            ofFill();
            ofSetColor(0,255,0);
            break;
        case 3:
            ofFill();
            ofSetColor(0,0,255);
            break;
        default:
            ofNoFill();
            ofSetColor(255);
            break;
    }
    //draw line
    if((lineEnd.x != -1) && bRulerOn && (touchMode == 1)&& !isFunctionID(lineStartID, functionIDs)){
        ofSetLineWidth(5);
        ofSetColor(pickColor);
        ofLine(lineStart.x,lineStart.y,lineEnd.x,lineEnd.y);
        ofSetColor(255);
        linePoints.push_back(linePointConstruct(lineStart, 1,pickColor));
        linePoints.push_back(linePointConstruct(lineEnd, 1,pickColor));
        lineEnd = ofPoint(-1,-1,0);
        tempLineEnd = ofPoint(-1,-1,0);
        lineStartID = -1;
        drawHistory.push_back("drawLine");
    }
    //draw real time line
    if(tempLineEnd.x != -1 && bRulerOn && (touchMode == 1)&& !isFunctionID(lineStartID, functionIDs)){
        //lineStart.y = ruler[0].y;
        ofSetLineWidth(5);
        ofSetColor(pickColor);
        ofLine(lineStart.x,lineStart.y,tempLineEnd.x,tempLineEnd.y);
        ofSetColor(255);

    }
    if(bRulerOn && (touchMode == 3) && (drawClearID != -1) && (drawHistory.size() > 0)){
        
        if(drawHistory[drawHistory.size()-1] == "drawLine"){
            linePoints.pop_back();
            linePoints.pop_back();
            cout << "line clear!" << endl;
        }
        else{
            if(curve_count > 0)
                curve_count--;
            curvePoints[curve_count].clear();
            cout << "curve clear!" << endl;
        }
        drawHistory.pop_back();
        drawClearID = -1;
    }
    if(touchMode == 2){

        drawSector(pattles[0], pattles[1], pattles[3], ofColor(255,0,0));
        drawSector(pattles[3], pattles[1], pattles[4], ofColor(0,255,0));
        drawSector(pattles[4], pattles[1], pattles[2], ofColor(0,0,255));

        for (int i=0; i<nonFunctionIDs.size(); ++i) {
            ofPoint t = touches[nonFunctionIDs[i]];
            if (points2distance(t, pattles[1]) < PATTLE_SIZE) {
                if((points2Rad(t, pattles[1]) > points2Rad(pattles[0], pattles[1])) && (points2Rad(t, pattles[1]) < points2Rad(pattles[3], pattles[1])))
                    pickColor = ofColor(255, 0, 0,0);
                else if((points2Rad(t, pattles[1]) > points2Rad(pattles[3], pattles[1])) && (points2Rad(t, pattles[1]) < points2Rad(pattles[4], pattles[1])))
                    pickColor = ofColor(0, 255, 0,0);
                else if((points2Rad(t, pattles[1]) > points2Rad(pattles[4], pattles[1])) && (points2Rad(t, pattles[1]) < points2Rad(pattles[2], pattles[1])))
                    pickColor = ofColor(0, 0, 255,0);
            }
            
        }
        ofSetColor(pickColor);
    }
    if(curveDrawing && !bRulerOn && curvePoints[curve_count].size()){
        
        for (int j = 0; j+1 < curvePoints[curve_count].size(); ++j) {
            //cout << curvePoints[curve_count][j].position << endl;
            if (curvePoints[curve_count][j].type == 1) {
                if((curvePoints[curve_count][j+1].position.x == -1) || (curvePoints[curve_count][j].position.x == -1))
                    break;
                ofSetLineWidth(5);
                ofSetColor(curvePoints[curve_count][j].drawColor);
                ofLine(curvePoints[curve_count][j].position.x,curvePoints[curve_count][j].position.y,curvePoints[curve_count][j+1].position.x,curvePoints[curve_count][j+1].position.y);
                ofSetColor(255);
            }
        }
        
        
    }
    
    
    for (int i=0; i<nonFunctionIDs.size(); ++i) {
        ofPoint t = touches[nonFunctionIDs[i]];
        ofCircle(t.x, t.y, CIRCLE_SIZE);
        ofLine(t.x-CIRCLE_SIZE, t.y, t.x+CIRCLE_SIZE, t.y);
        ofLine(t.x, t.y-CIRCLE_SIZE, t.x, t.y+CIRCLE_SIZE);

    }
    ofSetColor(255);
    ofNoFill();
    
    
    
}


//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    touches[touch.id].x = touch.x;
    touches[touch.id].y = touch.y;
    bTouchDown = true;

    if(touch.id!=leftRulerID && touch.id!=rightRulerID && bRulerOn && (touchMode == 1)){
        
        lineEnd = ofPoint(-1,-1,0);
        lineStart.x = touch.x;
        lineStart.y = ruler[0].y + slope * (touch.x - ruler[0].x);
        lineStartID = touch.id;
    }
    if(touch.id!=leftRulerID && touch.id!=rightRulerID && !bRulerOn){
        
        vector<linePointsStruct> init;
        curvePoints.push_back( init );
        
        ofPoint temp;
        temp.x = touch.x;
        temp.y = touch.y;
        
        curvePoints[curve_count].push_back( linePointConstruct(temp, 1,pickColor) );
        curveDrawing = true;
    }
    
    if(touch.id!=leftRulerID && touch.id!=rightRulerID && bRulerOn && (touchMode==3) ){
        drawClearID = touch.id;
    }

}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
    touches[touch.id].x = touch.x;
    touches[touch.id].y = touch.y;
    if(lineStartID != -1 && bRulerOn){
        lineStart.y = ruler[0].y + slope * (lineStart.x - ruler[0].x);
        tempLineEnd.x = touch.x;
        tempLineEnd.y = ruler[0].y + slope * (touch.x - ruler[0].x);
        
    }
    if (curveDrawing && !bRulerOn) {
        curvePoints[curve_count].push_back( linePointConstruct(ofPoint(touch.x, touch.y, 0), 1,pickColor) );
    }
    if(bRulerOn){
        curvePoints[curve_count].clear();
    }
    
    
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    
    if(lineStartID != -1 && (touchMode == 1)){
        lineEnd.x = touch.x;
        lineEnd.y = ruler[0].y + slope * (touch.x - ruler[0].x);
        lineStartID = -1;
    }
    if(curveDrawing && !bRulerOn){
        curvePoints[curve_count].push_back( linePointConstruct(ofPoint(-1, -1, 0), 1,pickColor) );
        curveDrawing = false;
//        for (int i = 0; i < curvePoints[curve_count].size(); ++i) {
//            cout << curvePoints[curve_count][i].position << endl;
//        }
        if(bRulerOn){
            curvePoints[curve_count].clear();
        }
        else
        {
            ++curve_count;
            drawHistory.push_back("drawCurve");
        }
    }
    
    if(drawClearID != -1 && (touchMode == 3)){
        drawClearID = -1;
    }
    
    
    touches[touch.id].x = -999;
    touches[touch.id].y = -999;
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
//    cout << touch.x << touch.y <<endl;
    if(touch.x < 200 && touch.y <200){
        linePoints.clear();
        for (int i = 0; i < curvePoints.size(); ++i) {
            curvePoints[i].clear();
        }
    }
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}

//--------------------------------------------------------------
float testApp::points2Angle(ofPoint p1, ofPoint p2){
    return round(atan2(p1.x-p2.x,p1.y-p2.y) *180./3.14159)-90.;
}
//--------------------------------------------------------------
float testApp::points2Rad(ofPoint p1, ofPoint p2){
    float a = points2Angle(p1, p2);
    return (a * 3.14159)/180.;
}
//--------------------------------------------------------------
float testApp::points2distance(ofPoint p1, ofPoint p2){
    return sqrt(float((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y)) );
}
//--------------------------------------------------------------
//Reference: http://paulbourke.net/geometry/pointlineplane/
float testApp::point2LineDistance(ofPoint p0, ofPoint p1, ofPoint p2){
    float mag = points2distance(p1,p2);
    float u   = ( (p0.x-p1.x) * (p2.x-p1.x) + (p0.y-p1.y) * (p2.y-p1.y) )/ (mag*mag);
    if( u < 0.0f || u > 1.0f ) return 0;
    ofPoint px = ofPoint( p1.x + u*((p2.x-p1.x)), p1.y + u * (p2.y-p1.y) );
    return points2distance(p0,px);
}
linePointsStruct testApp::linePointConstruct(ofPoint Position, int type, ofColor pickColor){
    linePointsStruct temp;
    temp.position = ofPoint(Position.x, Position.y,0);
    temp.type = type;
    temp.drawColor = pickColor;
    return temp;
}

bool testApp::isFunctionID(int a, vector<int> b){
    bool flag = false;
    for(int i = 0; i < b.size(); ++i){
        if(a == b[i])
            flag = true;
    }
    return flag;
}

void testApp::drawSector(ofPoint a, ofPoint b, ofPoint c, ofColor pickColor){
    float r = (a-b).length();
    cout << r << endl;
    float angle1 = points2Rad(a,b);
    float angle2 = points2Rad(c,b);
//    cout << b.x + r * cos(angle1) << " " << b.y - r * sin(angle1) << endl;
//    cout << a.x << " " << a.y << endl;
//    cout << points2Rad(a,b) << endl;
//    cout << points2Rad(c,b) << endl;
//    cout << (points2Rad(c, b) - points2Rad(a,b)) * 180 / PI <<endl;
    vector<ofPoint> temp;
    temp.push_back(a);
    for(int i = 0; i < (int)((angle2 - angle1) * 180 / PI); ++i){
        float increseAngle = (angle1*180 / PI + i) * PI / 180;
        temp.push_back(ofPoint(b.x + r * cos(increseAngle),b.y - r * sin(increseAngle),0));
    }
    temp.push_back(c);
    ofFill();
    ofSetColor(pickColor);
    ofBeginShape();
    ofVertex(b);
    for (int i = 0; i < temp.size(); ++i) {
        ofVertex(temp[i]);
    }
//    ofTriangle( a, b, c);
    ofEndShape();
}
