﻿const string commentBegin = "/" + "*";
const string commentEnd   = "*" + "/";

void main()
{
	LoadScene("empty");

	const string[] ethanonShaders = {
		"Cg/defaultVS.cg",
		"Cg/defaultPS.cg",
		"Cg/hAmbientVS.cg",
		"Cg/particleVS.cg",
		"Cg/highlightPS.cg",
		"Cg/solidPS.cg",
		"GLSL/default.ps",
		"GLSL/highlight.ps",
		"GLSL/solid.ps",
		"GLSL/default.vs",
		"GLSL/hAmbient.vs",
		"GLSL/optimal.vs",
		"GLSL/particle.vs"
	};

	const string relativePath = GetResourceDirectory() + "../../../Source/src/shaders/";
	convertShaderCodeToCHeader(
		@ethanonShaders,
		relativePath,
		relativePath,
		"shaders.h",
		"ETH_DEFAULT_SHADERS_H_",
		"ETHGlobal");

	const string[] gs2dDefaultShaders = {
		"GL/default-sprite-add.fs",
		"GL/default-sprite-fast.vs",
		"GL/default-sprite-highlight.fs",
		"GL/default-sprite-modulate.fs",
		"GL/default-sprite-solid-color-add.fs",
		"GL/default-sprite-solid-color-modulate.fs",
		"GL/default-sprite-solid-color.fs",
		"GL/default-sprite.fs",
		"GL/default-sprite.vs"
	};

	const string gs2dSavePath = GetResourceDirectory() + "../../../Source/src/gs2d/src/Video/GL/";
	convertShaderCodeToCHeader(
		@gs2dDefaultShaders,
		relativePath,
		gs2dSavePath,
		"GLShaderCode.h",
		"GL_SHADER_CODE_H_",
		"gs2d_shaders");
	Exit();
}

void convertShaderCodeToCHeader(
	const string[]@ shaders,
	const string &in relativePath,
	const string &in savePath,
	const string &in headerName,
	const string &in headerSafeWord,
	const string &in namespaceWord)
{
	string output = assembleFileHeader(shaders, headerSafeWord, namespaceWord);

	for (uint t = 0; t < shaders.length(); t++)
	{
		const string filePath = relativePath + shaders[t];
		if (FileExists(filePath))
		{
			output += "const std::string " + extractStringDeclName(shaders[t]) + " = \n";

			const string shaderCode = GetStringFromFile(filePath);
			const string[] lines = split(shaderCode, "\n");
			for (uint l = 0; l < lines.length(); l++)
			{
				output += "\"" + lines[l] + "\\n" + "\" " + "\\" + "\n";
			}
			output += "\"\\n\";\n\n";
		}
		else
		{
			print("FILE NOT FOUND! " + filePath);
		}
	}

	output += fileSufix;
	SaveStringToFile(savePath + headerName, output);
}

string assembleFileHeader(
	const string[]@ shaders,
	const string &in headerSafeWord,
	const string &in namespaceWord)
{
	const int tabSize = 42;
	string shadersIncluded = commentBegin + " Shaders included in this file:\n";
	for (uint t = 0; t < shaders.length(); t++)
	{
		string spaces;
		for (int s = 0; s < (tabSize - int(shaders[t].length())); s++)
			spaces += " ";
		shadersIncluded += shaders[t] + spaces + "->     " + extractStringDeclName(shaders[t]) + "\n";
	}
	shadersIncluded += commentEnd + "\n";

	return
	commentBegin + " This file has been generated by the ShaderToCHeader tool. Do not edit! " + commentEnd + "\n"
	"\n"
	"#ifndef " + headerSafeWord + "\n"
	"#define " + headerSafeWord + "\n"
	"\n"
	"#include <string>\n"
	"\n" +
	shadersIncluded +
	"\nnamespace " + namespaceWord + " {\n"
	"\n";	
}

const string fileSufix = "\n}\n\n#endif\n";

/// Create C++ string name based on shader file name
string extractStringDeclName(string fileName)
{
	string r;
	string[] majorPieces = split(fileName, ".");
	fileName = majorPieces[0];

	fileName = replace(fileName, "\\", "/");
	fileName = replace(fileName, "-", "_");

	string[] pieces = split(fileName, "/");
	r += pieces[pieces.length() - 1] + "_" + majorPieces[1];
	return r;
}

string replace(const string &in str, const string &in sequence, const string &in replace)
{
	string r;
	string[] pieces = split(str, sequence);
	const uint len = pieces.length();
	if (len >= 2)
	{
		for (uint t = 0; t < pieces.length() - 1; t++)
		{
			r += pieces[t] + replace;
		}
		r += pieces[len - 1];
	}
	else
	{
		r = str;
	}
	return r;
}

string[] split(string str, const string c)
{
	string[] v;
	uint64 pos;
	while ((pos = str.find(c)) != NPOS)
	{
		v.insertLast(str.substr(0, pos));
		str = str.substr(pos + c.length(), NPOS);
	}
	v.insertLast(str);
	return v;
}

