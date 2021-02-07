# EINIS PROJECT A.Y. 2020/21 - Andrea Murino
# Detection of plagiarism in programming code

import os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

source_files = [doc for doc in os.listdir() if doc.endswith('.r')]
print(source_files)
source_streams =[open(File).read() for File in source_files]

vectorize = lambda Text: TfidfVectorizer().fit_transform(Text).toarray()
similarity = lambda doc1, doc2: cosine_similarity([doc1, doc2])

vectors = vectorize(source_streams)
s_vectors = list(zip(source_files, vectors))
plagiarism_results = set()

def check_plagiarism():
    global s_vectors
    for code_a, text_vector_a in s_vectors:
        new_vectors =s_vectors.copy()
        current_index = new_vectors.index((code_a, text_vector_a))
        del new_vectors[current_index]
        for code_b , text_vector_b in new_vectors:
            sim_score = similarity(text_vector_a, text_vector_b)[0][1]
            code_pair = sorted((code_a, code_b))
            score = (code_pair[0], code_pair[1],sim_score)
            plagiarism_results.add(score)
    return plagiarism_results

for data in check_plagiarism():
    print(data)