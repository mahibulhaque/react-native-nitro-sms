#include <jni.h>
#include "NitroSmsOnLoad.hpp"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
  return margelo::nitro::nitrosms::initialize(vm);
}
