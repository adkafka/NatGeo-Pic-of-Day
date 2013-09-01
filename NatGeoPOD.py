#!/opt/local/bin/python

#Prints url to picture from index.html
def getPic():
    from BeautifulSoup import BeautifulSoup
    html=BeautifulSoup(open("index.html"))
    photoDiv=html.body.find('div', attrs={'class':'primary_photo'})
    print photoDiv.img['src']

#Main method
def main():
    getPic()

#Run Main method
main()
