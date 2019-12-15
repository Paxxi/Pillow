cmake_minimum_required(VERSION 3.16)

file(STRINGS src/PIL/version.py _pillow_version_str REGEX "__version__ = '[0-9.]+'")
string(REGEX REPLACE "__version__ = '([0-9.]+).*$" "//1" PILLOW_VERSION ${_pillow_version_str})
unset(_pillow_version_str)

project(pillow VERSION 6.2.1 LANGUAGES C)

find_package(python REQUIRED NO_MODULE)
find_package(freetype REQUIRED NO_MODULE)
find_package(zlib REQUIRED NO_MODULE)
find_package(libjpeg-turbo REQUIRED NO_MODULE)

list(APPEND INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/libImaging)

function(addPythonExtension name)
  cmake_parse_arguments(addPythonExtension "" "" "SOURCES;LIBRARIES;MACROS;INCLUDES" ${ARGN})
  add_library(${name} SHARED ${addPythonExtension_SOURCES})
  set_target_properties(${name}
    PROPERTIES
      SUFFIX ".pyd"
      PDB_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      PDB_NAME ${name}
  )
  target_include_directories(${name} PRIVATE $<BUILD_INTERFACE:${addPythonExtension_INCLUDES};${CMAKE_CURRENT_SOURCE_DIR}/src/libImaging/>)
  target_compile_definitions(${name} PRIVATE ${addPythonExtension_MACROS})
  target_compile_options(${name} PRIVATE /sdl- /MP)
  target_link_libraries(${name}
    PRIVATE
      python::pythoncore
      $<$<CONFIG:Debug>:vccorlibd.lib>
      $<$<CONFIG:RelWithDebInfo>:vccorlib.lib>
      $<$<CONFIG:Debug>:msvcrtd.lib>
      $<$<CONFIG:RelWithDebInfo>:msvcrt.lib>
  )
  target_link_options(${name}
    PRIVATE
      /NODEFAULTLIB:vccorlibd
      /NODEFAULTLIB:msvcrtd
      /NODEFAULTLIB:vccorlib
      /NODEFAULTLIB:msvcrt
      /INCREMENTAL:NO
      /debug
)
  foreach(lib ${addPythonExtension_LIBRARIES})
    target_link_libraries(${name} PRIVATE ${lib})
  endforeach()
  install(TARGETS ${name}
    RUNTIME DESTINATION bin/Python/Lib/site-packages/PIL
  )
  install(FILES
    $<TARGET_PDB_FILE:${name}>
    DESTINATION lib
  )
endfunction()

addPythonExtension(_imaging
  SOURCES
    src/_imaging.c
    src/decode.c
    src/display.c
    src/encode.c
    src/map.c
    src/outline.c
    src/path.c
    src/libImaging/Access.c
    src/libImaging/AlphaComposite.c
    src/libImaging/Bands.c
    src/libImaging/BcnDecode.c
    src/libImaging/Bit.h
    src/libImaging/BitDecode.c
    src/libImaging/Blend.c
    src/libImaging/BoxBlur.c
    src/libImaging/Chops.c
    src/libImaging/codec_fd.c
    src/libImaging/ColorLUT.c
    src/libImaging/Convert.c
    src/libImaging/ConvertYCbCr.c
    src/libImaging/Copy.c
    src/libImaging/Crop.c
    src/libImaging/Dib.c
    src/libImaging/Draw.c
    src/libImaging/Effects.c
    src/libImaging/EpsEncode.c
    src/libImaging/File.c
    src/libImaging/Fill.c
    src/libImaging/Filter.c
    src/libImaging/FliDecode.c
    src/libImaging/Geometry.c
    src/libImaging/GetBBox.c
    src/libImaging/Gif.h
    src/libImaging/GifDecode.c
    src/libImaging/GifEncode.c
    src/libImaging/HexDecode.c
    src/libImaging/Histo.c
    src/libImaging/Imaging.h
    src/libImaging/ImagingUtils.h
    src/libImaging/ImDib.h
    src/libImaging/ImPlatform.h
    src/libImaging/Jpeg.h
    src/libImaging/Jpeg2K.h
    src/libImaging/Jpeg2KDecode.c
    src/libImaging/Jpeg2KEncode.c
    src/libImaging/JpegDecode.c
    src/libImaging/JpegEncode.c
    src/libImaging/Matrix.c
    src/libImaging/ModeFilter.c
    src/libImaging/Negative.c
    src/libImaging/Offset.c
    src/libImaging/Pack.c
    src/libImaging/PackDecode.c
    src/libImaging/Palette.c
    src/libImaging/Paste.c
    src/libImaging/PcdDecode.c
    src/libImaging/PcxDecode.c
    src/libImaging/PcxEncode.c
    src/libImaging/Point.c
    src/libImaging/Quant.c
    src/libImaging/QuantHash.c
    src/libImaging/QuantHash.h
    src/libImaging/QuantHeap.c
    src/libImaging/QuantHeap.h
    src/libImaging/QuantOctree.c
    src/libImaging/QuantOctree.h
    src/libImaging/QuantPngQuant.c
    src/libImaging/QuantPngQuant.h
    src/libImaging/QuantTypes.h
    src/libImaging/RankFilter.c
    src/libImaging/raqm.h
    src/libImaging/Raw.h
    src/libImaging/RawDecode.c
    src/libImaging/RawEncode.c
    src/libImaging/Resample.c
    src/libImaging/Sgi.h
    src/libImaging/SgiRleDecode.c
    src/libImaging/Storage.c
    src/libImaging/SunRleDecode.c
    src/libImaging/TgaRleDecode.c
    src/libImaging/TgaRleEncode.c
    src/libImaging/TiffDecode.c
    src/libImaging/TiffDecode.h
    src/libImaging/Unpack.c
    src/libImaging/UnpackYCC.c
    src/libImaging/UnsharpMask.c
    src/libImaging/XbmDecode.c
    src/libImaging/XbmEncode.c
    src/libImaging/Zip.h
    src/libImaging/ZipDecode.c
    src/libImaging/ZipEncode.c
  LIBRARIES
    libjpeg-turbo::jpeg-static
    zlib::zlibstatic
  MACROS
    PILLOW_VERSION="${PILLOW_VERSION}"
    HAVE_LIBZ
    HAVE_LIBJPEG
)

addPythonExtension(_imagingft
  SOURCES
    src/_imagingft.c
  LIBRARIES
    freetype::freetype
)

addPythonExtension(_imagingmath SOURCES src/_imagingmath.c)
addPythonExtension(_imagingmorph SOURCES src/_imagingmorph.c)

install(DIRECTORY src/PIL DESTINATION bin/Python/Lib/site-packages)
