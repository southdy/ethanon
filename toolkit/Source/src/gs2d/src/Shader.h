#ifndef GS2D_SHADER_H_
#define GS2D_SHADER_H_

#include "Types.h"

#include "Math/Matrix4x4.h"
#include "Math/Color.h"

#include <boost/shared_array.hpp>
#include <boost/any.hpp>

namespace gs2d {

class Video;

/**
 * \brief Provides a render context to the shaders
 */
class ShaderContext
{
public:
	virtual boost::any GetContextPointer() = 0;
};

typedef boost::shared_ptr<ShaderContext> ShaderContextPtr;

/**
 * \brief Abstracts a shader object
 *
 * Stores, manages and binds a fragment or vertex shader.
 */
class Shader
{
public:
	virtual bool LoadShaderFromFile(
		ShaderContextPtr context,
        const std::string& vsFileName,
        const std::string& vsEntry,
        const std::string& psFileName,
        const std::string& psEntry) = 0;

	virtual bool LoadShaderFromString(
		ShaderContextPtr context,
        const std::string& vsShaderName,
        const std::string& vsCodeAsciiString,
        const std::string& vsEntry,
        const std::string& psShaderName,
        const std::string& psCodeAsciiString,
        const std::string& psEntry) = 0;

	virtual void SetConstant(const str_type::string& name, const math::Vector4 &v) = 0;
	virtual void SetConstant(const str_type::string& name, const math::Vector3 &v) = 0;
	virtual void SetConstant(const str_type::string& name, const math::Vector2 &v) = 0;
	virtual void SetConstant(const str_type::string& name, const float x) = 0;
	virtual void SetConstant(const str_type::string& name, const int n) = 0;
	virtual void SetConstantArray(const str_type::string& name, unsigned int nElements, const boost::shared_array<const math::Vector2>& v) = 0;
	virtual void SetMatrixConstant(const str_type::string& name, const math::Matrix4x4 &matrix) = 0;
	virtual void SetTexture(const str_type::string& name, TextureWeakPtr pTexture, const unsigned int index) = 0;
	
	virtual bool SetShader() = 0;
};

typedef boost::shared_ptr<Shader> ShaderPtr;

} // namespace gs2d

#endif
