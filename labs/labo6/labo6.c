#include <math.h>  // sqrt
#include <stdio.h> // printf, scanf

double ecart_type(double tab[], unsigned long n);
double    moyenne(double tab[], unsigned long n);

static unsigned long temp;
static double notes[1000];

static const char* fmtTaille = "%lu";
static const char* fmtDonnee = "%lf";
static const char* fmtSortie = "%lf\n";

int main()
{
    scanf(fmtTaille, &temp);

    unsigned long n = temp;
    unsigned long i = 0;

    while (i < n)
    {
      scanf(fmtDonnee, &notes[i]);
      i++;
    }

    double ecart = ecart_type(notes, n);

    printf(fmtSortie, ecart);

    return 0;
}

/*******************************************************************************
  Entrée: adresse d'un tableau de nombres en virgule flottante double précision
          nombre d'éléments du tableau
  Sortie: écart-type des éléments du tableau (en tant que population)
*******************************************************************************/
double ecart_type(double tab[], unsigned long n)
{
  return 0.0;
}

/*******************************************************************************
  Entrée: adresse d'un tableau de nombres en virgule flottante double précision
          nombre d'éléments du tableau
  Sortie: moyenne des éléments du tableau
*******************************************************************************/
double moyenne(double tab[], unsigned long n)
{
    unsigned long i = 0;
    double acc = 0.0;

    while (i < n)
    {
      double val = tab[i];
      acc += val;
      i++;
    }

    double moy = acc / n;

    return moy;
}
