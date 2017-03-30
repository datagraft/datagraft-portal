## ISTAT 2011 census cells
This dataset subdivides the region of Piemonte in census sections according to ISTAT’s 2011 National Census. A census section is the smallest geographic unit for which the statistical variables of a population census are taken.

Performed with the so-called classic method (or conventional census), by filling down a questionnaire administered by self-compilation and sometimes interview. Several e are several models of this survey tool: the sheet of the family, to live together, the buildings, the street numbers. The information requested relates to a snapshot of Italy on a particular day of the year:

* house (its characteristics)
* people of the family (personal data, education, profession, place where the activity takes place of work / study)
* people who do not usually live in house (occasionally dwelt people (guests) or persons temporarily present (living there at the time of the census, but then return in the municipality of residence).


## ISTAT 2011 census cells transformation
This transformation transforms data about census sections according to ISTAT’s 2011 National Census. A census section is the smallest geographic unit for which the statistical variables of a population census are taken. Creates a new column for identifying a census section based on the **municipality number** and **section identifier within the municipality**. Creates a new column for the **ISTAT municipality identifier** (seven-digits, preceded by zeros). RDF transformation is linked to the *ISTAT census RDF endpoint* and uses the *[proDataMarket vocabulary](http://vocabs.datagraft.net/proDataMarket)* concept of cencus cell.