#!/usr/bin/env python3
import csv

def readDemand(printDebug):
   with open('Gams_data.csv', newline='\n') as csvfile:
      data = csv.reader(csvfile, delimiter=',', quotechar='"')
      next(data)
      lines = []
      for l in data:
         lines.append(l)
 
      nb_indices = 3
   
      keys = {
            0: "macro",
            1: "micro",
            2: "city",
            }
   
      indices = {
            "macro" : set(),
            "micro" : set(),
            "city" : set(),
            }
   
      for line in lines:
         for i in range(nb_indices):
            key = keys[i]
            indices[key].add(line[i])
      
      macros = list(indices["macro"])
      micros = list(indices["micro"])
      citys = list(indices["city"])
   
      macros.sort()
      micros.sort()
      citys.sort()
   
      keySet = [macros, micros, citys]
   
      Dict = {}
      for macro in macros:
         Dict.update({macro : {}})
         for micro in micros:
            Dict[macro].update({micro : {}})
            for city in citys:
               Dict[macro][micro].update({city : 0})
 
      for l in lines:
         macro = l[0]
         micro = l[1]
         city = l[2]
         value = float(l[3])
         Dict[macro][micro][city] = value

      if(printDebug):
         counter = 1
         print('\n\nPRINTTING DICTIONARY: \n')
         for macro in macros:
            for micro in micros:
               for city in citys:
                  if Dict[macro][micro][city] != 0:
                     print(str(counter) + " " + macro + " " + micro + " "
                           + city + ": ", end="")
                     print(Dict[macro][micro][city])
                     counter = counter + 1
         print('')
   
      return Dict, keySet



def main(): 
   printDebug = False
   bahia, keySet = readDemand(printDebug)
         
   macros, micros, citys = keySet[0], keySet[1], keySet[2]

   print('\nMICRO-REGIONS PER MACRO:\n')

   for macro in macros:
      aux = []
      for micro in micros:
         for city in citys:
            if bahia[macro][micro][city] != 0:
               aux.append(micro)
               break
      print(macro + '.(' + ','.join(aux) + ')')
   
   print('\nCITIES PER MICRO-REGIONS:\n')

   for macro in macros:
      for micro in micros:
         flag = False
         cities = []
         for city in citys:
            if bahia[macro][micro][city] != 0:
               flag = True
               cities.append(city)
         if cities:
            print(micro + '.(' + ','.join(cities) + ')')
   

if __name__ == "__main__":
   main()
