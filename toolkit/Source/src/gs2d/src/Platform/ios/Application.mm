#import "Application.h"

#import <Video.h>
#import <Audio.h>
#import <Input.h>

#import <BaseApplication.h>

#import <Platform/NativeCommandManager.h>
#import <Platform/ios/IOSFileIOHub.h>
#import <Platform/ios/IOSNativeCommandListener.h>

#import <Input/iOS/IOSInput.h>

static gs2d::VideoPtr g_video;
static gs2d::InputPtr g_input;
static gs2d::AudioPtr g_audio;
static gs2d::BaseApplicationPtr g_engine;

Platform::NativeCommandManager ApplicationWrapper::m_commandManager;

ApplicationWrapper::ApplicationWrapper() : m_pixelDensity(1.0f)
{
	m_touches   = [[NSMutableArray alloc] init];
	m_arrayLock = [[NSLock alloc] init];

	// setup default subplatform
	const bool constant = false;
	gs2d::Application::SharedData.Create("com.ethanonengine.subplatform", "apple", constant);

	NSString* appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	gs2d::Application::SharedData.Create("com.ethanonengine.versionName", [appVersionString UTF8String], constant);

	// setup language code
	NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSRange designatorRange = NSMakeRange(0, 2);
	language = [language substringWithRange:designatorRange];
	gs2d::Application::SharedData.Create("ethanon.system.language", [language cStringUsingEncoding:1], true);
}

void ApplicationWrapper::Start(GLKView* view)
{
	g_audio = gs2d::CreateAudio(0);
	g_input = gs2d::CreateInput(false);

	Platform::FileIOHubPtr fileIOHub(new Platform::IOSFileIOHub("data/"));

	const gs2d::math::Vector2 size = GetScreenSize(view);
	g_video = gs2d::CreateVideo(static_cast<unsigned int>(size.x), static_cast<unsigned int>(size.y), fileIOHub);

	g_engine = gs2d::CreateBaseApplication();
	g_engine->Start(g_video, g_input, g_audio);

	m_pixelDensity = [view contentScaleFactor];
	
	m_commandManager.InsertCommandListener(Platform::IOSNativeCommmandListenerPtr(new Platform::IOSNativeCommmandListener));
}

void ApplicationWrapper::Update()
{
	if (!g_engine) return;

	// iOS Apps should not force quit
	/*if (g_video->HandleEvents() == gs2d::Application::APP_QUIT)
	{
		exit(0);
	}*/
	
	g_input->Update();
	g_audio->Update();

	const float elapsedTime = (gs2d::ComputeElapsedTimeF(g_video));
	g_engine->Update(gs2d::math::Min(400.0f, elapsedTime));
	
	m_commandManager.RunCommands(g_video->PullCommands());
}

void ApplicationWrapper::RenderFrame(GLKView *view)
{
	if (!g_engine)
	{
		Start(view);
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
		glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
	}
	else
	{
		g_engine->RenderFrame();
	}
}

void ApplicationWrapper::Destroy()
{
	g_engine->Destroy();
}

void ApplicationWrapper::Restore()
{
	if (g_engine)
	{
		g_engine->Restore();
	}
}

gs2d::math::Vector2 ApplicationWrapper::GetScreenSize(GLKView *view)
{
	return gs2d::math::Vector2(
		view.drawableWidth,
		view.drawableHeight
	);
}

void ApplicationWrapper::DetectJoysticks()
{
	if (g_input)
	{
		g_input->DetectJoysticks();
	}
}

void ApplicationWrapper::ForceGamepadPause()
{
	gs2d::IOSInput* input = static_cast<gs2d::IOSInput*>(g_input.get());
	if (input)
	{
		input->ForceGamepadPause();
	}
}

void ApplicationWrapper::TouchesBegan(UIView* thisView, NSSet* touches, UIEvent* event)
{
	[m_arrayLock lock];
	gs2d::IOSInput* input = static_cast<gs2d::IOSInput*>(g_input.get());

	for (UITouch *touch in touches)
	{
		unsigned int touchIdx = 0;
		bool added = false;

		NSUInteger count = [m_touches count];
		for (NSUInteger ui = 0; ui < count; ui++)
		{
			id storedTouch = [m_touches objectAtIndex:ui];
			if (storedTouch == nil || storedTouch == [NSNull null])
			{
				touchIdx = static_cast<unsigned int>(ui);
				[m_touches setObject:touch atIndexedSubscript:ui];
				added = true;
				break;
			}
		}

		if (!added)
		{
			touchIdx = static_cast<unsigned int>(count);
			[m_touches addObject:touch];
			added = true;
		}

		CGPoint location = [touch locationInView:thisView];
		input->SetCurrentTouchPos(touchIdx++, gs2d::math::Vector2(location.x, location.y) * m_pixelDensity);
	}
	[m_arrayLock unlock];
}

void ApplicationWrapper::TouchesMoved(UIView* thisView, NSSet* touches, UIEvent* event)
{
	[m_arrayLock lock];
	gs2d::IOSInput* input = static_cast<gs2d::IOSInput*>(g_input.get());
	for (UITouch *touch in touches)
	{
		NSUInteger touchIdx = [m_touches indexOfObject:touch];

		if (touchIdx != NSNotFound)
		{
			CGPoint location = [touch locationInView:thisView];
			input->SetCurrentTouchPos(
				static_cast<unsigned int>(touchIdx),
				gs2d::math::Vector2(location.x, location.y) * m_pixelDensity);
		}
		else
		{
			NSLog(@"TouchMoved touch not found!");
		}
	}
	[m_arrayLock unlock];
}

void ApplicationWrapper::TouchesEnded(UIView* thisView, NSSet* touches, UIEvent* event)
{
	[m_arrayLock lock];
	gs2d::IOSInput* input = static_cast<gs2d::IOSInput*>(g_input.get());
	for (UITouch *touch in touches)
	{
		NSUInteger touchIdx = [m_touches indexOfObject:touch];
		if (touchIdx != NSNotFound)
			[m_touches setObject:[NSNull null] atIndexedSubscript:touchIdx];
		if (touchIdx != NSNotFound)
		{
			input->SetCurrentTouchPos(static_cast<unsigned int>(touchIdx), gs2d::GS_NO_TOUCH);
		}
		else
		{
			NSLog(@"TouchEnded touch not found!");
		}
	}
	[m_arrayLock unlock];
}

void ApplicationWrapper::TouchesCancelled(UIView* thisView, NSSet* touches, UIEvent* event)
{
	TouchesEnded(thisView, touches, event);
}

void ApplicationWrapper::UpdateAccelerometer(CMAccelerometerData *accelerometerData)
{
	gs2d::IOSInput* input = static_cast<gs2d::IOSInput*>(g_input.get());
	input->SetAccelerometerData(gs2d::math::Vector3(
		static_cast<float>(accelerometerData.acceleration.x),
		static_cast<float>(accelerometerData.acceleration.y),
		static_cast<float>(accelerometerData.acceleration.z)));
}
