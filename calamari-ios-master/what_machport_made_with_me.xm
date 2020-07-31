/* machport and i worked on this for calamari, but as u can see its very very bad code. so i rewrote the whole thing without machports involvement */

#include <stdio.h>
#include <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <arm_neon.h>
#include "./Lua/LuauTranspiler.h"

@interface InputCapture : UIView @end
/*  File automatically generated with
        "BIN2C dog.bin"
    BIN2C (C) JRVV, ELECSAN S.A., 2016
    This program is freeware
*/

static const char __alphabet[] =
    "0123456789"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz";
NSString * randomString(int length)
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    u_int32_t alphabetLength = (u_int32_t)strlen(__alphabet);
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%c", __alphabet[arc4random_uniform(alphabetLength)]];
    }
    return randomString;
}
long long (*origfunc)(long long);
signed long long xua_readclosure(long long* a1, const char *a2, const char * a3, long long a4) {
    return ((( signed long long (*)(long long*, const char *, const char * , long long)) (0x100FBE2C4 + (long long)_dyld_get_image_vmaddr_slide(0)))(a1,a2,a3,a4));
}
void __fastcall xua_pushcclosure(long long * a1, long long a2, long a3, long a4, long a5) {
    (((__fastcall void  (*)(long long *,long long,long, long, long ))(0x100F1FDDC + (long long)_dyld_get_image_vmaddr_slide(0)))(a1,a2,a3,a4,a5));
}
long long xua_pcall(long long *a1, int a2, int a3, int a4) {
    return(((  __fastcall long long (*)(long long *, int , int , int))( 0x100F20E10 + (long long)_dyld_get_image_vmaddr_slide(0)))(a1,a2,a3,a4));
}
long long xua_getfield(long long * a1, long long a2, const char *a3) {
    return((( __fastcall long long (*)(long long *, long long , const char *)) (0x100F20008 + (long long)_dyld_get_image_vmaddr_slide(0)))(a1,a2,a3));
}
const char* xua_tolstring(long long* L, long long idx, long long size) {
    return((( __fastcall const char *(*)(long long* , long long , long long )) (0x100F1F2A0 + (long long)_dyld_get_image_vmaddr_slide(0)))(L,idx,size));
}
long  xua_getglobalstate(long long *a1) {
    return (( long(*)(long long*))( 0x1007ADA88 + (long long)_dyld_get_image_vmaddr_slide(0)))(a1);
}
int loadstringFunc(long long* L){
NSLog(@"loadstring called");
    long size;
auto the_str =  xua_tolstring(L, 1, 0);
if (!the_str) {
    the_str = "error('Failed to load.')";
}
    NSLog(@"compiling");
     auto code = LuauTranspiler::compile(lua_open(), the_str );
    NSLog(@"readclosure 1");
   xua_readclosure(L, [[@"=" stringByAppendingString:randomString(5)] UTF8String], code.c_str(), code.size());
       NSLog(@"readclosure 2");

return 1;
}
int lua_dostring(long long* L, const char * c) {
    auto code = LuauTranspiler::compile(lua_open(), c);
    xua_readclosure(L, [[@"=" stringByAppendingString:randomString(5)] UTF8String], code.c_str(), code.size());
    xua_pcall(L, 0, 0, 0);
}
int didit=0;
long long *global;
void setidentity(long long* L,long long identity) {
     *(long long*)(*(long long*)(((long long)L)+ 168) + 48LL) = identity;
}
long long hook(long long *L) {
    if ((long)__builtin_return_address(0) == (0x01007B619C + (long long)_dyld_get_image_vmaddr_slide(0))) {
        while (didit != 1){
        didit = 1;
        setidentity(L,6);
            auto code = LuauTranspiler::compile(lua_open(), "local args = {...}; spawn(function() local genCode = unpack(args); genCode(game:GetService('InsertService'):LoadLocalAsset('http://roblox.com/asset?id=4986720531&t=' .. tick()).Source)(unpack(args)); end)");
            NSLog(@"%s",code.c_str());
            xua_readclosure(L, [[@"=" stringByAppendingString:randomString(5)] UTF8String], code.c_str(), code.size());
            xua_pushcclosure(L, (long long)loadstringFunc, 0, 0,0);
            xua_pcall(L, 1, 0, 0);
        
        NSLog(@"%p",global);

    }
    }
    return origfunc((long long)L);
}
int e = 0;
%hook AppsFlyerUtils
+(bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2 { return NO; }
%end
int hookd = 0;
%hook InputCapture
-(id)init:(CGRect)arg1 vrMode:(BOOL)arg2 {
    if (e == 0) { 
    e += 1; return %orig(); 
    } else { 
    if (hookd !=1) {
        MSHookFunction((void*)(0x100F1E610 + (long long)_dyld_get_image_vmaddr_slide(0)), (void*)&hook, (void**)&origfunc);
        hookd = 1;
    }
    didit =0;
    } 
    return %orig();
}
%end

