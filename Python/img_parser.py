from HTMLParser import HTMLParser
from urllib2 import urlopen
import os
import os.path
from urlparse import urljoin
from urllib import urlretrieve
 
def get_url():
    """
    -Prompts user to enter a URL in the format 'http://...'
    Accepts both upper and lower case letters.
    Does not check if URL exists, only if it is in the right format.
    
    -returns: A URL in the correct format.
    """
    
    valid = False
    while not valid:
        myurl = raw_input("Please enter a URL: ")
        if myurl.lower().startswith("http://"):
            valid = True
        else:
            print "Invalid URL, make sure URL is in the format 'http://'" 
    return myurl
 
def get_outfolder():
    """
    -Prompts user to enter the output directory for the images.
    Checks to see if the folder already exists.
    
    -If folder does not exist, get_outfolder creates the directory then
    checks to see if write privileges can be given.
    
    -returns: An output destination for the images.
    """
    
    valid = False
    while not valid:
        fname = raw_input("Please enter directory to save images. ")
        if not os.path.exists(fname):
            os.makedirs(fname)
        #Check to see if the file is there.
        if os.path.exists(fname): 
            valid = True
        #File is not there, check to see if write privileges can be given
        #to created file.
        elif os.access(os.path.dirname(fname), os.W_OK):
            valid = True
        else:
            print "Invalid local path, please try again."
    return fname
    
def find_img_urls(mainURL):
    """
    -Parses the url returned by get_url, finds all <img> tags, and adds the
    source URL (relative or absolute) to a list.
    
    -returns: A list of URLs, both absolute and relative.
     """
    
    imglist = []
    
    class IMGParser(HTMLParser):
        def handle_starttag(self, tag, attrs):
            if tag == 'img':
                imglist.append(dict(attrs)["src"])
                
    URL = urlopen(mainURL)
    html = URL.read()
    
    parser = IMGParser()
    parser.feed(html)
    parser.close()
    
    return imglist
 
def download_imgs(img_urls, outfolder):
    """
    -Downloads the URLs in the img_urls list to folder outfolder.
    
    -Takes each image link in img_urls and saves it to outputfolder.
    
    -Images are named after the text that occurs after the last slash
    '/' in the image URL.
    
    -If an image cannot be downloaded from an image link, download_imgs
    skips it.
    """
    
    print "Downloading %d images from: " %len(img_urls), url
    
    for image in img_urls:
        filename = image.split('/')[-1]
        outpath = os.path.join(outfolder, filename)
        img_url = urljoin(url, image)
        try:
            urlretrieve(image, outpath)
            print img_url, "downloaded successfully."
            
        except IOError:
            print "Failed to download file:", img_url
            pass
 
if __name__ == "__main__":
    url = get_url()
    outfolder = get_outfolder()
    img_urls = find_img_urls(url)
    download_imgs(img_urls, outfolder)