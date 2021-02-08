# EINIS PROJECT A.Y. 2020/21 - Andrea Murino
# Detection of plagiarism in programming code

# Importing all necessary modules
import os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# loading all the path textfiles on our project directory
source_files = [doc for doc in os.listdir() if doc.endswith('.txt')]
print(source_files)
source_streams =[open(File).read() for File in source_files]

# lambda function vectorize will convert the text to arrays of numbers
vectorize = lambda Text: TfidfVectorizer().fit_transform(Text).toarray()
# lambda function similarity will compute the similarity between them
similarity = lambda doc1, doc2: cosine_similarity([doc1, doc2])

# let's vectorize the loaded source files
vectors = vectorize(source_streams)
s_vectors = list(zip(source_files, vectors))

# The set that will contain the results of the similarity among the source files
score_results = set()
plagiarism_results = set()
threshold = 0.9 # Above this threshold we'll consider the plagiarism

# The actual function that will compute the similarity
def check_plagiarism():
    global s_vectors
    for code_a, text_vector_a in s_vectors:
        new_vectors = s_vectors.copy()
        current_index = new_vectors.index((code_a, text_vector_a))
        del new_vectors[current_index]
        for code_b , text_vector_b in new_vectors:
            sim_score = similarity(text_vector_a, text_vector_b)[0][1]
            code_pair = sorted((code_a, code_b))
            score = (code_pair[0], code_pair[1],sim_score)  # preparing the element
            if sim_score > threshold:                       # if the score is higher than the threshold, the plagiarism is detected
                plagiarism_results.add(score)
            else:
                score_results.add(score)
    
    results = {"score": score_results, "plagiarism": plagiarism_results}
    return results

results = check_plagiarism()
# let's print the score of all the comparisons
print('The score of all the comparisons: ')
for res in results['score'].union(results['plagiarism']):
    print(res)

#let's print the plagiarism code (if any detected)
print('\nDetected plagiarism: ')
if len(results['plagiarism']) !=  0:
    for res in check_plagiarism()['plagiarism']:
        print(res)
else:
    print('No plagiarism detected')


