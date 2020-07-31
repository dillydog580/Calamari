#define HIDE __attribute__ ((visibility ("hidden")))

#include <stdio.h>
#include <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <arm_neon.h>

#include "./Lua/LuauTranspiler.h"
@interface InputCapture : UIView @end

NSString* HIDE randomString(int length)
{
    static const char __alphabet[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz";
    NSMutableString* randomString = [NSMutableString stringWithCapacity : length];
    u_int32_t alphabetLength = (u_int32_t)strlen(__alphabet);
    for (int i = 0; i < length; i++) {
        [randomString appendFormat : @"%c", __alphabet[arc4random_uniform(alphabetLength)]] ;
    }
    return randomString;
}

/* external definitions */
#define DF(Name, Address, Return, ...) HIDE typedef Return(__fastcall *t_##Name)(__VA_ARGS__); static t_##Name Name = (t_##Name)offsetLoc(Address);
static long long HIDE offsetLoc(long long address) {
    return address + (long long)_dyld_get_image_vmaddr_slide(0);
}

#define xua_State long long
HIDE typedef int(*xua_CFunction) (xua_State X);

typedef struct HIDE xuaL_Reg {
    const char* name;
    xua_CFunction func;
} xuaL_Reg;

namespace Offsets {
    HIDE long long xua_extraspace = 168;                             // Unable to create a new thread for %s  |  Look for xua_setidentity
    HIDE long long xua_newthread_address = offsetLoc(0x0000000100E911F8);   // Unable to create a new thread for %s     |   Look for xua_newthread.
    HIDE long long xua_newthread_return = offsetLoc(0x0000000100326B48);    // Unable to create a new thread for %s     |   Look for xua_newthread, and find the next instruction after call (after BL)
    DF(
        xua_readclosure, 0x0000000100EA6FE8, int, xua_State X, const char* chunkname, const char* code, long size
    ); // bytecode version mismatch   |   Container sub is the address.
    DF(
        xua_pushcclosure, 0x0000000100E920CC, void, xua_State X, xua_CFunction func, const char* funcname, int ups, xua_CFunction altfunc
    ); // xpcall   |   String is an argument to a sub, which is the address.
    DF(
        xua_pcall, 0x0000000100E92BD8, int, xua_State X, int args, int rets, int errorfunc
    ); // *** Value not found ***   |   Look for directly above: if (xua_pcall(X, 0, 1, 0))
    DF(
        xua_tolstring, 0x0000000100E91A38, const char*, xua_State X, int idx, size_t* size
    ); // *** Value not found ***   |   Look for directly above: if (xua_pcall(X, 0, 1, 0))
}

using namespace Offsets;
void HIDE xua_setidentity(xua_State X, long long identity) {
    *(long long*)(*(long long*)(X + xua_extraspace) + 48LL) = identity;
}
int HIDE xuaL_loadbuffer(xua_State X, const char* script, size_t len, const char* chunkname) {
    auto code = LuauTranspiler::compile(lua_open(), script);
    return xua_readclosure(X, chunkname, code.c_str(), code.size());
}

int HIDE xuaL_loadstring(xua_State X, const char* script) {
    return xuaL_loadbuffer(X, script, strlen(script), script);
}

int HIDE xua_dostring(xua_State X, const char* c) {
    xuaL_loadstring(X, c);
    xua_pcall(X, 0, 0, 0);
}

/* custom api */
namespace Environment {
    int HIDE loadstringFunc(xua_State X) {
        auto source = xua_tolstring(X, 1, NULL);
        if (!source)
            source = "error('Failed to load. dog ')";
        xuaL_loadbuffer(X, source, strlen(source), [[@"=" stringByAppendingString:randomString(5)]UTF8String]);
        return 1;
    }

    static HIDE const xuaL_Reg custom_api[] = {
        {"loadstring",     loadstringFunc},
        {NULL, NULL}
    };

    int HIDE loadFunctions(xua_State X) {
        int size = 0;
        auto api = custom_api;

        for (; api->name; api++){
            xua_pushcclosure(X, api->func, api->name, 0, NULL);
            size++;
        }

        return size; // count of custom functions
    }
}

/* theos init, and lua injection */
namespace InjectCalamari {
    bool HIDE game_loaded = false;
    bool HIDE hook_applied = false;
    bool HIDE init_lua = true;

    xua_State HIDE (*xua_newthread)(xua_State X);

    long long HIDE xua_newthread_hook(xua_State X) {
        if ((long)__builtin_return_address(0) == xua_newthread_return) { // at this point, global state is passed to newthread
            while (init_lua) {
                init_lua = false;
                xua_setidentity(X, 6);
                //5048633661 main UI
                //5025426267 tronx
                xuaL_loadstring(
                    X, "print('Calamari-iOS Loaded...'); local args = {...}; spawn(function() local genCode = unpack(args); genCode(game:GetService('InsertService'):LoadLocalAsset('http://roblox.com/asset?id=5048633661&t=' .. tick()).Source)(unpack(args)); end)"
                );
                if (xua_pcall(X, Environment::loadFunctions(X), 0, 0)) {
                    NSLog(@"There was an error: %s", (char*)xua_tolstring(X, -1, 0));
                }
            }
        }
        return xua_newthread(X);
    }
};

%hook AppsFlyerUtils
    +(bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2 { return NO; }
%end

%hook InputCapture
-(id)init:(CGRect)arg1 vrMode:(BOOL)arg2 {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calamari-iOS"
                                                            message:@"Calamari-iOS is cute. Marie love   s deat h"
                                                            delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                [alert show];
    if (!InjectCalamari::game_loaded) {
        InjectCalamari::game_loaded = true;
        return %orig();
    } 
    else {
        if (!InjectCalamari::hook_applied) {
            MSHookFunction((void*)(xua_newthread_address), (void*)&InjectCalamari::xua_newthread_hook, (void**)&InjectCalamari::xua_newthread);
            InjectCalamari::hook_applied = true;
        }
        InjectCalamari::init_lua = true;
    } 
    return %orig();
}
%end

