# Retrieve Clinvar ID by the given NANDO ID

## Parameters

* `nando_id` NANDO ID
  * default: 1200030
  * examples: 1200061
  
## Endpoint
https://togodx.dbcls.jp/human/sparql

## `nando2mondo2medgen`
```sparql
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mo: <http://med2rdf/ontology/medgen#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?mondo ?medgen_id ?medgen_cid 
WHERE {
  GRAPH <http://rdf.integbio.jp/dataset/togosite/nando>{ 
      nando:{{nando_id}} skos:closeMatch ?mondo .
    }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/medgen>{ 
    ?medgen_uri
    dct:identifier ?medgen ;
    mo:mgconso ?mgconso .
    ?mgconso
    dct:source mo:MONDO ;
    rdfs:seeAlso ?mondo.
    BIND (CONCAT("http://ncbi.nlm.nih.gov/medgen/",?medgen)AS ?medgen_id)
    BIND (IRI(?medgen_id)AS ?medgen_cid)
    }
}
 ```
 ## `medgen`
 ```javascript
({nando2mondo2medgen}) => {
  return nando2mondo2medgen.results.bindings.map(b => b.medgen_cid.value);
}

```
## Endpoint
https://grch38.togovar.org/sparql

## `medgen2clinvar2togovar`
```sparql
PREFIX cvo:    <http://purl.jp/bio/10/clinvar/>
PREFIX dct:    <http://purl.org/dc/terms/>
PREFIX medgen: <http://ncbi.nlm.nih.gov/medgen/>
PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio:    <http://semanticscience.org/resource/>
PREFIX tgvo:   <http://togovar.biosciencedbc.jp/vocabulary/>

SELECT DISTINCT ?tgv_id ?rs_id ?variant ?title ?interpretation ?review_status ?last_evaluated ?condition
WHERE {
  VALUES ?med_id { {{#each medgen}} <{{this}}> {{/each}} } 

  GRAPH <http://togovar.biosciencedbc.jp/clinvar> {
    ?med_id ^dct:references ?_interpreted_condition .

    ?_interpreted_condition rdfs:label ?condition ;
      ^cvo:interpreted_condition/^cvo:interpreted_condition_list ?_rcv .

    ?_rcv dct:identifier ?rcv ;
      cvo:date_last_evaluated ?last_evaluated ;
      cvo:interpretation ?interpretation ;
      ^cvo:rcv_accession/^cvo:rcv_list/^cvo:interpreted_record ?clinvar .

    ?clinvar a cvo:VariationArchiveType ;
      rdfs:label ?title ;
      cvo:accession ?vcv ;
      cvo:variation_id ?vid ;
      cvo:interpreted_record/cvo:review_status ?review_status ;
      cvo:interpreted_record/sio:SIO_000628/dct:references ?dbsnp .

    BIND(STR(?vid) AS ?variation_id)

    ?dbsnp rdfs:seeAlso ?rs_id ;
      dct:source ?dbname .
    FILTER(?dbname IN ("dbSNP"))
  }

  GRAPH <http://togovar.biosciencedbc.jp/variant/annotation/clinvar> {
    ?variant dct:identifier ?variation_id .
  }

  GRAPH <http://togovar.biosciencedbc.jp/variant> {
    ?variant dct:identifier ?tgv_id .
  }
}
                    
```
## result
```javascript
({medgen2clinvar2togovar}) => {
  const clinical_significance_key = (interpretation) => {
    switch (interpretation.toLowerCase()) {
      case "pathogenic":
        return "P";
      case "likely pathogenic":
        return "LP";
      case "uncertain significance":
        return "US";
      case "likely benign":
        return "LB";
      case "benign":
        return "B";
      case "conflicting interpretations of pathogenicity":
        return "CI";
      case "drug response":
        return "DR";
      case "association":
        return "A";
      case "risk factor":
        return "RF";
      case "protective":
        return "PR";
      case "affects":
        return "AF";
      case "other":
        return "O";
      case "not provided":
        return "NP";
      case "association_not found":
        return "AN";
      default:
    }
  };

  const review_status_stars = (review_status) => {
    switch (review_status) {
      case "no assertion provided":
        return 0;
      case "no assertion criteria provided":
        return 0;
      case "no assertion for the individual variant":
        return 0;
      case "criteria provided, single submitter":
        return 1;
      case "criteria provided, conflicting interpretations":
        return 1;
      case "criteria provided, multiple submitters, no conflicts":
        return 2;
      case "reviewed by expert panel":
        return 3;
      case "practice guideline":
        return 4;
      default:
    }
  };

  return medgen2clinvar2togovar.results.bindings.map(x => {
    const position = x.variant.value.match(/http:\/\/identifiers.org\/hco\/(.+)\/GRCh3[78]#(\d+)/);

    return {
      tgv_id: x.tgv_id.value,
      tgv_link: "/variant/" + x.tgv_id.value,
      rs_id: x.rs_id.value.replace("http://ncbi.nlm.nih.gov/snp/", ""),
      rs_id_link: x.rs_id.value.replace("http://", "https://"),
      position: position[1] + ":" + position[2],
      title: x.title.value,
      interpretation: `<span class="clinical-significance-full" data-sign="${clinical_significance_key(x.interpretation.value)}">${x.interpretation.value}</span>`,
      review_status: `<span class="star-rating"><span data-stars="${review_status_stars(x.review_status.value)}" class="star-rating-item"></span></span><br><span class="status-description">${x.review_status.value}</span>`,
      last_evaluated: x.last_evaluated.value,
    };
  });
}
```
## Description
- 過去のUIで使用していたSPARQListで現在は使われていません。（編集：高月）