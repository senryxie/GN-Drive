# -*- coding: utf-8 -*-
import Image
from cStringIO import StringIO

class PictureError(Exception): message = 'Picture Error'
class UnknownPictureError(PictureError): message = 'Unknown Picture'

def open_pic(image):
    """open a picture, and normalize

    image: a PIL Image object, image content string or file-like object
    """

    if hasattr(image, 'getim'): # a PIL Image object
        im = image
    else:
        if not hasattr(image, 'read'): # image content string
            image = StringIO(image)
        try:
            im = Image.open(image) # file-like object
        except IOError, e:
            if e.message == "cannot identify image file":
                raise UnknownPictureError()
            else:
                raise

    # use a white background for transparency effects
    # (alpha band as paste mask).
    if im.mode == 'RGBA' and im.format != 'PNG':
        p = Image.new('RGBA', im.size, 'white')
        p.format = im.format
        try:
            x, y = im.size
            p.paste(im, (0, 0, x, y), im)
            im = p
        except:
            pass
        del p

    if im.mode == 'P':
        need_rgb = True
    elif im.mode == 'L':
        # grey bitmap, fix fog cover
        need_rgb = True
    elif im.mode == 'CMYK':
        # fix the dark background
        need_rgb = True
    else:
        need_rgb = False

    if need_rgb:
        im = im.convert('RGB', dither=Image.NONE)

    return im

