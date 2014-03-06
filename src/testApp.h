#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"

#define PORT 12345
#define CIRCLE_SIZE 60
#define T2D_THLD 60
#define RULER_DIST 925
#define RULER_DELAY 20

#define PATTLE_SIZE 240
#define PI 3.14159
typedef struct linePointsStruct{
    ofPoint position;
    int type;
    ofColor drawColor;
};
class testApp : public ofxiPhoneApp {

public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);

    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    //--------------------------------------------------------------
    float points2Angle(ofPoint p1, ofPoint p2);
    float points2Rad(ofPoint p1, ofPoint p2);
    float points2distance(ofPoint p1, ofPoint p2);
    float point2LineDistance(ofPoint p, ofPoint p1, ofPoint p2);
    //--------------------------------------------------------------
    
    linePointsStruct linePointConstruct(ofPoint Position, int type, ofColor pickColor);
    bool isFunctionID(int a, vector<int> b);
    void drawSector(ofPoint a, ofPoint b, ofPoint c, ofColor pickColor);
    
    vector<ofPoint> touches;
    vector<ofPoint> ruler;
    vector<ofPoint> buttons;
    vector<int> functionIDs;
    vector<int> nonFunctionIDs;
    //save lines
    vector<linePointsStruct> linePoints;
    vector<vector<linePointsStruct> > curvePoints;
    vector<string> drawHistory;
    vector<ofPoint> pattles;
    
    ofPoint leftTouch = ofPoint(-1,-1,0);
    ofPoint rightTouch = ofPoint(-1,-1,0);
    ofPoint center = ofPoint(-1,-1,0);
    ofPoint lEdgeCenter = ofPoint(-1,-1,0);
    ofPoint rEdgeCenter = ofPoint(-1,-1,0);
    ofPoint lEdgeQuarter = ofPoint(-1,-1,0);
    ofPoint rEdgeQuarter = ofPoint(-1,-1,0);
    ofPoint pivot = ofPoint(-1,-1,0);
    
    ofPoint lineStart = ofPoint(-1,-1,0);
    ofPoint lineEnd = ofPoint(-1,-1,0);
    ofPoint tempLineEnd = ofPoint(-1, -1, 0);
    
    int lineStartID = -1;
    int drawClearID = -1;
    int curve_count = 0;
    bool curveDrawing = false;
    ofColor pickColor = ofColor(255,0,0,0);
    float slope = 1;
    
    ofImage BackgroundImg;
    bool pickMode = false;
    
    float angle;
    float dUp = 128 * 0.6;
    float dEdge = 128 * 0.5;
    
    
    int leftestTouchID = -1;
    int rightestTouchID = -1;
    bool bTouchDown = false;
    float maxDistance = -1;
    
    bool bRulerOn = false;
    int rulerCountDown = 0;
    int leftRulerID = -1;
    int rightRulerID = -1;
    
    int touchMode = 0;
    
    
};

