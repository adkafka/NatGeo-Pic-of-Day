#!/opt/local/bin/python

import sys
from bs4 import BeautifulSoup #Import BeautifulSoup


#Prints url to picture from index.html
def getPic(html):
    photoDiv=html.body.find('div', attrs={'class':'primary_photo'}) #Go to div that holds primary_photo
    return photoDiv.img['src'] #Get src of image

#Gets metadata info about the picture
def getInfo(html):
    captionDiv=html.body.find('div',attrs={'id':'caption'}) #Div where photo info is stored
    title=captionDiv.h2.text
    credit=captionDiv.find('p',attrs={'class':'credit'}).text #Spacing error if link is inside
    time=captionDiv.find('p',attrs={'class':'publication_time'}).text
    #Remove first line
    remove=captionDiv.find('p',{'class':None})
    remove.extract()
    #Description is the next element with no class
    desc=captionDiv.find('p',{'class':None}).text.strip() #rstrip removes new line chars 
    return title+"\n"+credit+"\n"+time+"\n"+desc

#Returns the link to the previous IMG of day
def getPrevLink(html):
    prevP=html.body.find('p',attrs={'class':'prev'}) #paragraph where link will be
    pathToNext=prevP.a['href']
    baseUrl="http://photography.nationalgeographic.com"
    return baseUrl+pathToNext

#Main method
def main():
    try:
        html=BeautifulSoup(open("temp.html")) #Read input from index.html
    except IOError:
        print("File not found")
        sys.exit(1)
    print(getPic(html)+"\n"+getInfo(html)+"\n"+getPrevLink(html))

#Run Main method
main()
