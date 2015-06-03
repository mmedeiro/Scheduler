//
//  Avaliacao.swift
//  
//
//  Created by Mariana Medeiro on 03/06/15.
//
//

import Foundation
import CoreData

class Avaliacao: NSManagedObject {

    @NSManaged var tipoAvaliacao: String
    @NSManaged var pesoAvaliacao: NSNumber
    @NSManaged var dataAvaliacao: NSDate
    @NSManaged var horarioAvaliacao: AnyObject
    @NSManaged var notaAvaliacao: NSNumber

}
