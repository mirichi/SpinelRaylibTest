#include <raylib.h>

#define TEX_MAX 100
Texture2D textures[TEX_MAX];
int textureIndex = 0;

int SpLoadTexture(const char *fileName) {
    textures[textureIndex] = LoadTexture(fileName);
    textureIndex++;
    return textureIndex - 1;
}

void SpUnloadTexture(int id) {
    UnloadTexture(textures[id]);
}

void SpDrawTexture(int id, int posX, int posY, Color tint) {
    DrawTexture(textures[id], posX, posY, tint);
}

void SpDrawTextureRec(int id, int sx, int sy, int sw, int sh, int px, int py, Color tint) {
    Rectangle source = { sx, sy, sw, sh };
    Vector2 position = { px, py };
    Texture2D texture = textures[id];
    DrawTextureRec(texture, source, position, tint);
}

float SpGetMouseX() {
    return GetMousePosition().x;
}

float SpGetMouseY() {
    return GetMousePosition().y;
}

void SpDrawTriangle(float v1x, float v1y, float v2x, float v2y, float v3x, float v3y, Color color) {
    Vector2 v1 = { v1x, v1y };
    Vector2 v2 = { v2x, v2y };
    Vector2 v3 = { v3x, v3y };
    DrawTriangle(v1, v2, v3, color);
}

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
void SpSleep(void) {
    emscripten_sleep(0); // ブラウザに制御を返し、次のフレームで再開する
}
#else
void SpSleep(void) {
    // Windows等のネイティブ環境では何もしない
}
#endif
