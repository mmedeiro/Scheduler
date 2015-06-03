//
//  Aluno.swift
//  
//
//  Created by Mariana Medeiro on 03/06/15.
//
//

import Foundation
import CoreData

class Aluno: NSManagedObject {

    @NSManaged var nome: String
    @NSManaged var curso: String
    @NSManaged var semestre: NSNumber
    @NSManaged var materia: String

}
