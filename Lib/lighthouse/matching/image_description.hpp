//
//  image_description.hpp
//  Lighthouse Camera
//
//  Created by Aleh Zasypkin on 23/12/2016.
//  Copyright © 2016 Lighthouse. All rights reserved.
//

#ifndef image_description_hpp
#define image_description_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <cereal/access.hpp>
#include <cereal/types/vector.hpp>

namespace lighthouse {

class ImageDescription {
public:
    ImageDescription(std::vector<cv::KeyPoint> aKeypoints, cv::Mat aDescriptors, cv::Mat aHistogram);

    const std::vector<cv::KeyPoint> GetKeypoints();
    const cv::Mat GetDescriptors();
    const cv::Mat GetHistogram();

    static void Save(const ImageDescription aDescription, const std::string aPath);
    static ImageDescription Load(const std::string aPath);

private:
    std::vector<cv::KeyPoint> mKeypoints;
    cv::Mat mDescriptors;
    cv::Mat mHistogram;

    friend class cereal::access;
    template<class Archive> void serialize(Archive& aArchive) {
        aArchive(mKeypoints);
        aArchive(mDescriptors);
        aArchive(mHistogram);
    };
};

} // namespace lighthouse

#endif /* image_description_hpp */
