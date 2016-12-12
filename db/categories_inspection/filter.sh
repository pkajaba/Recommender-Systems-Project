#!/bin/bash
cp -r ../all_jokes_from_selected_categories_data/ jokes
pushd jokes
  echo "Staring sorting jokes to categories"
  for f in *.txt
  do
    category=$(cat $f | tail -n 1| sed s/\ /_/g)
    mkdir -p -- $category
    sed -i "$ d" $f
    mv $f $category
  done
  echo "Sorting done"
popd

mkdir jokes_result

pushd lemma
  echo "Starting filtering"
  python3 lemmatization.py
  echo "Filtering ended"
popd
