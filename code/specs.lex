
/* Seccion de declaraciones e inicializaciones */
%{
#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

string game, specs, screen, description, retail_price, discount, final_price, price,
       video, tags, release_date;
char game_directory[50];

string to_flat_text(char* text);
string get_game_name(char* name);
void get_screens(char* text);
void get_price(char* text);
void get_video(char* text);
void get_tags(char* text);
%}

coin €
letra	[a-zA-Zá-úÁ-Ú]
digito	[0-9]
entero  [1-9]{digito}*
real  ({entero}".")|({entero}"."{digito}+)
identificador ({letra}|"_")({letra}|"_"|{digito})*
special [=™®:\'\"\-\.\(\)<>/ \t\n%_\"–“”,;#’&¡!¿?º°|ª•…以上]
pic_format  [png,jpg]
percent "%"
date  {entero}" "{letra}+" "{entero}
spec_total "<div class=\"hardspecs"({letra}|{special}|{entero})+("\*</div>"|"\*</td>")({letra}|{special}|{digito})+(("\*</div>"|"\*</td>")({letra}|{special}|{digito})+)*"<div class=\"asterix center\">"
game_name  "<h1>"({letra}|{special}|{digito})+"</h1>"
retail_price "<div class=\"retail"({letra}|{special}|{digito}|{real})+{coin}"</span> </div>"
discount "<div class=\"discount\">"({letra}|{special}|{digito})+{percent}"</div>"
final_price "<div class=\"price\">"{real}{coin}"</div>"
price "<div class=\"buy\">"({letra}|{special})+{retail_price}+"\n"{discount}+"\n"{final_price}+
description "<div class=\"description\""({letra}|{special}|{digito})+("</li></ul>"|"<span class=\"number\">"|"<br /"({letra}|{special})+"</div>")
screens  "<meta property=\"og:image\" content=\""({letra}|{special}|{digito})+"\."({pic_format})+"\" />"
video "<iframe id=\"ig-vimeo-player\" src=\""({letra}|{special}|{digito})+"</iframe>"
tags "<div class=\"tags\">"({letra}|{special}|{digito})+("<div class=\"moretags\">"|"</a> </div>")
release_date "<div class=\"release\">"({letra}|{special})+{date}
/* Seccion de reglas (expresiones regulares) */
%%

{game_name} {game = get_game_name(yytext);}
{spec_total} {specs = to_flat_text(yytext);}
{screens} {get_screens(yytext);}
{description} {description = to_flat_text(yytext);}
{price} {get_price(yytext);}
{video} {get_video(yytext);}
{tags} {get_tags(yytext);}
{release_date}  {release_date = to_flat_text(yytext);}

. {}
\n {}


%%
/* Seccion de codigo fuente y main */


int main(int argc, char *argv[]) {
  if (argc ==2) { // Se da fichero como entrada
    yyin= fopen(argv[1], "rt"); // Se abre fichero para lectura en modo texto
    if (!yyin) { // Error
      cout<< "No se pudo abrir el fichero "<< argv[1]<<endl;
      return 0;
    }

  } else { // No se da fichero como entrada: Se coge la entrada desde consola (entrada estandar)

    yyin= stdin;
  }

  yylex(); // Llamada al reconocedor
  ofstream ofs;
  char gname[50], buff[50], gfile[50];
  char* comando1 ="mv ";

  strcpy(gfile,game_directory);
  strcat(gfile,".txt");

  ofs.open (gfile, ofstream::out | ofstream::app);
  ofs << game << "\t\ttrailer:" + video << "\n\nGéneros: " << tags << "\n\n" << release_date << endl << specs << endl << description << endl << price << endl;
  ofs.close();

  strcpy(buff,comando1);
  strcat(buff,gfile);
  strcat(buff," ");
  strcat(buff,game_directory);

  int get = system(buff);

  return 0;
}

string to_flat_text(char* text) {
  string tmp(text), flat_text;
  bool label = false;

  for(string::iterator it=tmp.begin(); it!=tmp.end(); ++it) {
    if((*it) == '<')  label = true;
      else if ((*it) == '>') label = false;
        else  if(!label)  flat_text.push_back(*it);
  }
return flat_text;
}

string get_game_name(char* name) {
  string tmp(name), gname, gname_command;
  bool label = false;
  char buff[500], buff2[500];
  char* command ="mkdir ";
  char* comando1 ="cd ";
  char* comando2 =" && wget ";

  for(string::iterator it=tmp.begin(); it!=tmp.end(); ++it) {
    if((*it) == '<')  label = true;
      else if ((*it) == '>') label = false;
        else  if(!label) {
          if((*it) != '(' && (*it) != ')')  gname.push_back(*it);
          if(*it == ' ') gname_command.push_back('_');
            else if((*it) != '(' && (*it) != ')') gname_command.push_back(*it);
        }
  }

  strcpy(buff,command);
  strcat(buff,gname_command.c_str());
  strcpy(game_directory,gname_command.c_str());
  int get=system(buff);

  strcpy(buff2,comando1);
	strcat(buff2,game_directory);
	strcat(buff2,comando2);
	strcat(buff2,screen.c_str());
  int get2=system(buff2);

  return gname;
}

void get_screens(char* text) {
  bool start = false;
  char buff[500];
  char * comando1 ="cd ";
  char * comando2 =" && wget ";
  string tmp(text);

  for(string::iterator it=tmp.begin(); it!=tmp.end(); ++it) {
    if((*it) == 'h') {
        start = true;
        screen.push_back(*it);
    }else if (start && (*it) == '"' ) start = false;
           else  if(start) screen.push_back(*it);
  }

}

void get_price(char* text) {
  string tmp(text);
  bool label = false;
  int case_= 0;

  for(string::iterator it=tmp.begin(); it!=tmp.end(); ++it) {
    if((*it) == '<')  label = true;
      else if ((*it) == '>') label = false;
        else  if(!label)
                if(!label) { if((*it) == '\n') price += " "; else price.push_back(*it);}
  }
}

void get_video(char* text) {
  string tmp(text);
  bool url = false, end = false;

  for(string::iterator it=tmp.begin(); it!=tmp.end() && !end; ++it) {
    if((*it) == 'h') url = true;

    if(url && ((*it) == '"')) {url = false;end=true;}

    if(url) video.push_back(*it);
  }
}

void get_tags(char* text) {
  string tmp(text);
  bool label = false, insert=false;
  int case_=0;

  for(string::iterator it=tmp.begin(); it!=tmp.end(); ++it) {
    if((*it) == '<')  label = true;
      else if ((*it) == '>') label = false;
        else  if(!label)  {
          switch (case_) {
            case 0: if((*it) == '\n') case_ = 1;
                      else tags.push_back(*it);
                    break;
            case 1: if((*it) == '\n' || (*it) == ' ') tags+=", ";
                      else tags.push_back(*it);
            break;
          }

        }
  }
  tags.pop_back();tags.pop_back();
}
