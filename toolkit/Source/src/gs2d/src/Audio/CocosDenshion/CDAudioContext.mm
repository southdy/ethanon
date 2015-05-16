/*--------------------------------------------------------------------------------------
 Ethanon Engine (C) Copyright 2008-2013 Andre Santee
 http://ethanonengine.com/

	Permission is hereby granted, free of charge, to any person obtaining a copy of this
	software and associated documentation files (the "Software"), to deal in the
	Software without restriction, including without limitation the rights to use, copy,
	modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
	and to permit persons to whom the Software is furnished to do so, subject to the
	following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
	CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
	OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--------------------------------------------------------------------------------------*/

#import "CDAudioContext.h"
#import "CocosDenshion/SimpleAudioEngine.h"

namespace gs2d {

GS2D_API AudioPtr CreateAudio(boost::any data)
{
	AudioPtr audio = CDAudioContext::Create(data);
	if (audio)
	{
		return audio;
	}
	else
	{
		return AudioPtr();
	}
}

boost::shared_ptr<CDAudioContext> CDAudioContext::Create(boost::any data)
{
	boost::shared_ptr<CDAudioContext> p(new CDAudioContext());
	p->weak_this = p;
	if (p->CreateAudioDevice(data))
	{
		return p;
	}
	else
	{
		return CDAudioContextPtr();
	}
}

CDAudioContext::CDAudioContext() :
	m_logger(Platform::FileLogger::GetLogDirectory() + "CDAudioContext.log.txt")
{
	SetGlobalVolume(1.0f);
}

bool CDAudioContext::CreateAudioDevice(boost::any data)
{
	m_logger.Log("Audio device initialized", Platform::FileLogger::INFO);
	return true;
}

boost::any CDAudioContext::GetAudioContext()
{
	return 0;
}

bool CDAudioContext::IsStreamable(const Audio::SAMPLE_TYPE type)
{
	switch (type)
	{
	case Audio::SOUND_EFFECT:
		return false;
	case Audio::MUSIC:
		return true;
	case Audio::SOUNDTRACK:
		return true;
	case Audio::AMBIENT_SFX:
		return true;
	case Audio::UNKNOWN_TYPE:
	default:
		return false;
	}
}

void CDAudioContext::SetGlobalVolume(const float volume)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:volume];
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:volume];
	[pool release];
}

float CDAudioContext::GetGlobalVolume() const
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	const float r = [[SimpleAudioEngine sharedEngine] effectsVolume]; 
	[pool release];
	return r;
}

} // namespace gs2d
