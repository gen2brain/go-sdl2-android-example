package main

import "C"

import (
	"path/filepath"
	"runtime"

	"github.com/veandco/go-sdl2/sdl"
	"github.com/veandco/go-sdl2/sdl_image"
	"github.com/veandco/go-sdl2/sdl_mixer"
	"github.com/veandco/go-sdl2/sdl_ttf"
)

const (
	// Window title
	WinTitle = "Go SDL2 Example"
	// Window width
	WinWidth = 480
	// Window height
	WinHeight = 800
)

// Game states
const (
	StateRun = iota
	StateFlap
	StateDead
)

// States text
var stateText = map[int]string{
	StateRun:  "RUN",
	StateFlap: "FLAP",
	StateDead: "DEAD",
}

// SDL engine structure
type Engine struct {
	State     int
	Window    *sdl.Window
	Renderer  *sdl.Renderer
	Sprite    *sdl.Texture
	Font      *ttf.Font
	Music     *mix.Music
	Sound     *mix.Chunk
	StateText map[int]*Text
	running   bool
}

// State text structure
type Text struct {
	Width   int32
	Height  int32
	Texture *sdl.Texture
}

// Returns new engine
func NewEngine() (e *Engine) {
	e = &Engine{}
	e.running = true
	return
}

// Initializes SDL
func (e *Engine) Init() (err error) {
	err = sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO)
	if err != nil {
		return
	}

	err = mix.Init(mix.INIT_OGG)
	if err != nil {
		return
	}

	err = ttf.Init()
	if err != nil {
		return
	}

	err = mix.OpenAudio(mix.DEFAULT_FREQUENCY, mix.DEFAULT_FORMAT, mix.DEFAULT_CHANNELS, 3072)
	if err != nil {
		return
	}

	e.Window, err = sdl.CreateWindow(WinTitle, sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, WinWidth, WinHeight, sdl.WINDOW_SHOWN)
	if err != nil {
		return
	}

	e.Renderer, err = sdl.CreateRenderer(e.Window, -1, sdl.RENDERER_ACCELERATED)
	if err != nil {
		return
	}

	return
}

// Destroys SDL and releases the memory
func (e *Engine) Destroy() {
	for _, v := range e.StateText {
		v.Texture.Destroy()
	}

	e.Sprite.Destroy()
	e.Font.Close()
	e.Music.Free()
	e.Sound.Free()
	e.Renderer.Destroy()
	e.Window.Destroy()

	ttf.Quit()
	mix.CloseAudio()
	mix.Quit()
	sdl.Quit()
}

// Quits main loop
func (e *Engine) Quit() {
	e.running = false
}

// Checks if loop is running
func (e *Engine) Running() bool {
	return e.running
}

// Loads sprite
func (e *Engine) LoadSprite(file string) (err error) {
	e.Sprite, err = img.LoadTexture(e.Renderer, file)
	return
}

// Loads ttf font
func (e *Engine) LoadFont(file string, size int) (err error) {
	e.Font, err = ttf.OpenFont(file, size)
	return
}

// Loads music
func (e *Engine) LoadMusic(file string) (err error) {
	e.Music, err = mix.LoadMUS(file)
	return
}

// Loads sound chunk
func (e *Engine) LoadSound(file string) (err error) {
	e.Sound, err = mix.LoadWAV(file)
	return
}

// Loads resources
func (e *Engine) Load() {
	assetDir := filepath.Join("..", "android", "assets")
	if runtime.GOOS == "android" {
		assetDir = ""
	}

	err := e.LoadSprite(filepath.Join(assetDir, "images", "sprite.png"))
	if err != nil {
		sdl.LogError(sdl.LOG_CATEGORY_APPLICATION, "LoadSprite: %s\n", err)
	}

	err = e.LoadFont(filepath.Join(assetDir, "fonts", "universalfruitcake.ttf"), 24)
	if err != nil {
		sdl.LogError(sdl.LOG_CATEGORY_APPLICATION, "LoadTexture: %s\n", err)
	}

	err = e.LoadMusic(filepath.Join(assetDir, "music", "frantic-gameplay.ogg"))
	if err != nil {
		sdl.LogError(sdl.LOG_CATEGORY_APPLICATION, "LoadMusic: %s\n", err)
	}

	err = e.LoadSound(filepath.Join(assetDir, "sounds", "click.wav"))
	if err != nil {
		sdl.LogError(sdl.LOG_CATEGORY_APPLICATION, "LoadSound: %s\n", err)
	}

	e.StateText = map[int]*Text{}
	for k, v := range stateText {
		t, _ := e.RenderText(v, sdl.Color{0, 0, 0, 0})
		_, _, tW, tH, _ := t.Query()
		e.StateText[k] = &Text{tW, tH, t}
	}
}

// Renders texture from ttf font
func (e *Engine) RenderText(text string, color sdl.Color) (texture *sdl.Texture, err error) {
	surface, err := e.Font.RenderUTF8_Blended(text, color)
	if err != nil {
		return
	}
	defer surface.Free()

	texture, err = e.Renderer.CreateTextureFromSurface(surface)
	return
}

func run() {
	runtime.LockOSThread()
	e := NewEngine()

	// Initialize SDL
	err := e.Init()
	if err != nil {
		sdl.LogError(sdl.LOG_CATEGORY_APPLICATION, "Init: %s\n", err)
	}
	defer e.Destroy()

	// Sprite size
	const n = 128

	// Sprite rects
	var rects []*sdl.Rect
	for x := 0; x < 6; x++ {
		rect := &sdl.Rect{int32(n * x), 0, n, n}
		rects = append(rects, rect)
	}

	// Load resources
	e.Load()

	// Play music
	e.Music.Play(-1)

	var frame int = 0
	var alpha uint8 = 255
	var showText bool = true

	var text *Text = e.StateText[StateRun]

	for e.Running() {

		for event := sdl.PollEvent(); event != nil; event = sdl.PollEvent() {
			switch t := event.(type) {
			case *sdl.QuitEvent:
				e.Quit()

			case *sdl.MouseButtonEvent:
				e.Sound.Play(2, 0)
				if t.Type == sdl.MOUSEBUTTONDOWN && t.Button == sdl.BUTTON_LEFT {
					alpha = 255
					showText = true

					if e.State == StateRun {
						text = e.StateText[StateFlap]
						e.State = StateFlap
					} else if e.State == StateFlap {
						text = e.StateText[StateDead]
						e.State = StateDead
					} else if e.State == StateDead {
						text = e.StateText[StateRun]
						e.State = StateRun
					}
				}

			case *sdl.KeyDownEvent:
				if t.Keysym.Scancode == sdl.SCANCODE_ESCAPE || t.Keysym.Scancode == sdl.SCANCODE_AC_BACK {
					e.Quit()
				}
			}
		}

		e.Renderer.Clear()

		var clips []*sdl.Rect

		w, h := e.Window.GetSize()
		x, y := int32(w/2), int32(h/2)

		switch e.State {
		case StateRun:
			e.Renderer.SetDrawColor(168, 235, 254, 255)
			clips = rects[0:2]

		case StateFlap:
			e.Renderer.SetDrawColor(251, 231, 240, 255)
			clips = rects[2:4]

		case StateDead:
			e.Renderer.SetDrawColor(255, 250, 205, 255)
			clips = rects[4:6]
		}

		clip := clips[frame/2]

		e.Renderer.FillRect(nil)
		e.Renderer.Copy(e.Sprite, clip, &sdl.Rect{x - (n / 2), y - (n / 2), n, n})

		if showText {
			text.Texture.SetAlphaMod(alpha)
			e.Renderer.Copy(text.Texture, nil, &sdl.Rect{x - (text.Width / 2), y - n*1.5, text.Width, text.Height})
		}

		e.Renderer.Present()
		sdl.Delay(50)

		frame += 1
		if frame/2 >= 2 {
			frame = 0
		}

		alpha -= 10
		if alpha <= 10 {
			alpha = 255
			showText = false
		}
	}
}

// Exports function to C
//export main2
func main2() {
	run()
}

// Go main function
func main() {
	run()
}
