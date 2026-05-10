#include <raylib.h>

/* uint32 → Color 変換ヘルパー
   Spinel は Color を r + g*256 + b*65536 + a*16777216 でパックしている */
static inline Color sp_u32_to_color(unsigned int v) {
    Color c;
    c.r = (unsigned char)(v & 0xFF);
    c.g = (unsigned char)((v >> 8) & 0xFF);
    c.b = (unsigned char)((v >> 16) & 0xFF);
    c.a = (unsigned char)((v >> 24) & 0xFF);
    return c;
}

/* --- Texture管理 --- */
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

void SpDrawTexture(int id, int posX, int posY, unsigned int tint) {
    DrawTexture(textures[id], posX, posY, sp_u32_to_color(tint));
}

void SpDrawTextureRec(int id, int sx, int sy, int sw, int sh, int px, int py, unsigned int tint) {
    Rectangle source = { sx, sy, sw, sh };
    Vector2 position = { px, py };
    Texture2D texture = textures[id];
    DrawTextureRec(texture, source, position, sp_u32_to_color(tint));
}

/* --- Mouse --- */
float SpGetMouseX() {
    return GetMousePosition().x;
}

float SpGetMouseY() {
    return GetMousePosition().y;
}

/* --- Drawing (Color構造体を正しく渡すラッパー) --- */
void SpDrawTriangle(float v1x, float v1y, float v2x, float v2y, float v3x, float v3y, unsigned int color) {
    Vector2 v1 = { v1x, v1y };
    Vector2 v2 = { v2x, v2y };
    Vector2 v3 = { v3x, v3y };
    DrawTriangle(v1, v2, v3, sp_u32_to_color(color));
}

void SpClearBackground(unsigned int color) {
    ClearBackground(sp_u32_to_color(color));
}

void SpDrawText(const char *text, int posX, int posY, int fontSize, unsigned int color) {
    DrawText(text, posX, posY, fontSize, sp_u32_to_color(color));
}

void SpDrawRectangle(int posX, int posY, int width, int height, unsigned int color) {
    DrawRectangle(posX, posY, width, height, sp_u32_to_color(color));
}

void SpDrawRectangleLines(int posX, int posY, int width, int height, unsigned int color) {
    DrawRectangleLines(posX, posY, width, height, sp_u32_to_color(color));
}

void SpDrawLine(int startPosX, int startPosY, int endPosX, int endPosY, unsigned int color) {
    DrawLine(startPosX, startPosY, endPosX, endPosY, sp_u32_to_color(color));
}

/* --- Emscripten support --- */
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
void SpSleep(void) {
    emscripten_sleep(0);
}
#else
void SpSleep(void) {
    // Windows等のネイティブ環境では何もしない
}
#endif
