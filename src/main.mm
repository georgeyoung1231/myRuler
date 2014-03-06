#include "ofMain.h"
#include "testApp.h"

int main(){
    ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
    
    iOSWindow->enableRetinaSupport();
    
    ofSetupOpenGL(2048, 1536, OF_FULLSCREEN);	 // <-------- setup the GL context
    ofRunApp(new testApp);
}
